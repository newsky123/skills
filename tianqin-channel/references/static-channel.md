# Static Channel Activation (静态传输通道激活)

## Overview

Static configuration allows apps to receive channel connection requests without starting the process. When a remote device initiates a connection to your service, your process is woken via `bindService` and receives the connection request callback.

**Key Points:**
- Complements dynamic API with process wake-up capability
- Does NOT provide keep-alive functionality
- Process is started via `bindService`, auto-unbinds after 10s of no callbacks
- After wake-up, immediately register `ChannelListener` to handle the connection
- Connection initiator has timeout - register listener quickly to avoid failure

**Power Consideration:** Static configuration triggers networking on boot, increasing power consumption. Use sparingly with user-controllable switches.

## Configuration

### AndroidManifest.xml Setup

```xml
<!-- Permissions -->
<uses-permission android:name="com.xiaomi.permission.BIND_CONTINUITY_SERVICE" />
<uses-permission android:name="com.xiaomi.permission.BIND_CONTINUITY_SERVICE_INTERNAL" />

<service
    android:name=".ContinuitySampleService"
    android:enabled="true"
    android:exported="true"
    android:permission="com.xiaomi.permission.BIND_CONTINUITY_LISTENER_SERVICE">
    <intent-filter>
        <action android:name="com.xiaomi.continuity.action.STATIC_CONFIG_ACTION" />
    </intent-filter>
    <!-- Static service publishing with channel activation -->
    <meta-data
        android:name="static_networking_service_list"
        android:resource="@xml/networking_service_list" />
</service>
```

### Service Implementation

```java
public class ContinuitySampleService extends ContinuityListenerService {
    @MainThread
    @Override
    public void onNotify(@NonNull Intent intent) {
        String action = intent.getAction();
        Bundle extras = intent.getExtras();

        if (StaticConfig.ACTION_REQUEST_CONNECTION.equals(action)) {
            // Channel connection request - register listener immediately!
            ServiceName serviceName = extras.getParcelable(StaticConfig.EXTRA_SERVICE_NAME);
            handleConnectionRequest(serviceName);
        }
    }

    private void handleConnectionRequest(ServiceName serviceName) {
        ContinuityChannelManager channelManager = ContinuityChannelManager.getInstance(this);

        ServerChannelOptions options = new ServerChannelOptions.Builder()
            .setTrustLevel(TrustLevel.SAME_ACCOUNT)
            .build();

        // Register immediately - connection has timeout!
        channelManager.registerChannelListener(serviceName, options, new ChannelListener() {
            @Override
            public void onChannelConfirm(String deviceId, ServiceName serviceName,
                    int channelId, ConfirmInfo confirmInfo) {
                if (SameAccountConfirmUtils.isConfirmForAndroidSameApp(
                        ContinuitySampleService.this, confirmInfo)) {
                    channelManager.confirmChannel(channelId, ConfirmStatus.ACCEPT);
                } else {
                    channelManager.confirmChannel(channelId, ConfirmStatus.REFUSE);
                }
            }

            @Override
            public void onChannelCreateSuccess(@NonNull Channel channel) {
                // Channel ready - can now send/receive data
            }

            @Override
            public void onChannelCreateFailed(@NonNull ServiceName serviceName,
                    int channelId, int errorCode) {
                // Connection failed
            }

            @Override
            public void onChannelReceive(@NonNull Channel channel, @NonNull Packet packet) {
                // Handle received data
            }

            @Override
            public void onChannelRelease(@NonNull Channel channel, int code) {
                // Channel closed
            }
        }, getMainExecutor());
    }
}
```

### Enable/Disable Static Configuration

```java
ComponentName componentName = new ComponentName(this, ContinuitySampleService.class);

// Enable
getPackageManager().setComponentEnabledSetting(componentName,
    PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
    PackageManager.DONT_KILL_APP);

// Disable
getPackageManager().setComponentEnabledSetting(componentName,
    PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
    PackageManager.DONT_KILL_APP);
```

## Static Service Publishing for Channel

### XML Configuration (res/xml/networking_service_list.xml)

To enable channel connection activation, set `notifyConnect="true"`:

```xml
<networking_service_list>
    <service
        serviceName="myChannelService"
        serviceData="[1,2,3]"
        needAddService="true"
        notifyConnect="true"
        trustLevel="sameAccount" />
</networking_service_list>
```

### Service Attributes

| Attribute | Description | Required |
|-----------|-------------|----------|
| `serviceName` | Service name (packageName auto-filled) | Yes |
| `serviceData` | JSON array of bytes (-128 to 127) | No |
| `notifyConnect` | **Enable process wake-up on connection request** | No (default: false) |
| `needAddService` | Publish service (default: true) | No |
| `trustLevel` | Allowed trust levels: `sameAccount`, `trustGroup`, `everyOne` | No (2.2+) |

### P2P Lock Options (2.2+)

For P2P channel connections, configure lock options:

```xml
<service serviceName="myP2PService" notifyConnect="true">
    <p2pLockOptions
        tag="myP2PLock"
        seizePriority="1"
        beSeizedPriority="1"
        avoidWhiteList="tag1|tag2"
        coexistWhiteList="tag3"
        seizeWhiteList="tag4"
        acceptSeizeWhiteList="tag5"
        rejectSeizeWhiteList="tag6" />
</service>
```

## Connection Request Action

When `notifyConnect="true"` and a remote device initiates a channel connection, your service receives:

**Action:** `StaticConfig.ACTION_REQUEST_CONNECTION` (`com.xiaomi.continuity.action.REQUEST_CONNECTION`)

**Extras:**

| Name | Value | Type | Description |
|------|-------|------|-------------|
| `EXTRA_SERVICE_NAME` | `com.xiaomi.continuity.EXTRA_SERVICE_NAME` | `ServiceName` | The service being connected to |

### Handler Example

```java
@Override
public void onNotify(@NonNull Intent intent) {
    if (StaticConfig.ACTION_REQUEST_CONNECTION.equals(intent.getAction())) {
        ServiceName serviceName = intent.getExtras()
            .getParcelable(StaticConfig.EXTRA_SERVICE_NAME);

        // CRITICAL: Register channel listener immediately!
        // The connecting device has a timeout - if you take too long
        // to register the listener, the connection will fail.
        ContinuityChannelManager.getInstance(this)
            .registerChannelListener(serviceName, options, listener, executor);

        // After registering, you will receive:
        // 1. onChannelConfirm - verify and accept/reject
        // 2. onChannelCreateSuccess - channel ready for data transfer
    }
}
```

## Enable Switch Control

Control static component via Settings URI. Supports `()`, `&` (use `&amp;` in XML), `|` operators.

```xml
<!-- Default: Xiaomi connectivity switch -->
<meta-data android:name="static_enable_switch"
    android:value="{content://settings/secure/pref_key_connectivity_service_state}" />

<!-- Custom setting -->
<meta-data android:name="static_enable_switch"
    android:value="{content://settings/secure/my_app_channel_enabled}" />

<!-- Always enabled -->
<meta-data android:name="static_enable_switch"
    android:value="1" />

<!-- Logical combination -->
<meta-data android:name="static_enable_switch"
    android:value="{content://settings/global/Enabled1}&amp;{content://settings/global/Enabled2}" />
```

## Runtime Configuration Modification

Store dynamic settings in Settings URI:

```xml
<service
    serviceName="myService"
    serviceData="{content://settings/system/myServiceData}[2,3,5]"
    notifyConnect="true" />
```

If `content://settings/system/myServiceData` contains `[1,2,3]`, merged result is `[1,2,3,2,3,5]`.

## Complete Example

### AndroidManifest.xml

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="com.xiaomi.permission.BIND_CONTINUITY_SERVICE" />
<uses-permission android:name="com.xiaomi.permission.BIND_CONTINUITY_SERVICE_INTERNAL" />

<service
    android:name=".ChannelReceiverService"
    android:exported="true"
    android:permission="com.xiaomi.permission.BIND_CONTINUITY_LISTENER_SERVICE">
    <intent-filter>
        <action android:name="com.xiaomi.continuity.action.STATIC_CONFIG_ACTION" />
    </intent-filter>
    <meta-data
        android:name="static_networking_service_list"
        android:resource="@xml/channel_service_config" />
    <meta-data
        android:name="static_enable_switch"
        android:value="{content://settings/secure/pref_key_connectivity_service_state}" />
</service>
```

### res/xml/channel_service_config.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<networking_service_list>
    <service
        serviceName="fileReceiver"
        serviceData="[1]"
        needAddService="true"
        notifyConnect="true"
        trustLevel="sameAccount" />
</networking_service_list>
```

### ChannelReceiverService.java

```java
public class ChannelReceiverService extends ContinuityListenerService {
    private static final String TAG = "ChannelReceiverService";
    private ContinuityChannelManager mChannelManager;
    private Channel mChannel;

    @Override
    public void onCreate() {
        super.onCreate();
        mChannelManager = ContinuityChannelManager.getInstance(this);
    }

    @Override
    public void onNotify(@NonNull Intent intent) {
        if (StaticConfig.ACTION_REQUEST_CONNECTION.equals(intent.getAction())) {
            ServiceName serviceName = intent.getExtras()
                .getParcelable(StaticConfig.EXTRA_SERVICE_NAME);
            Log.i(TAG, "Connection request for: " + serviceName);
            registerChannelListener(serviceName);
        }
    }

    private void registerChannelListener(ServiceName serviceName) {
        ServerChannelOptions options = new ServerChannelOptions.Builder()
            .setTrustLevel(TrustLevel.SAME_ACCOUNT)
            .build();

        mChannelManager.registerChannelListener(serviceName, options, new ChannelListener() {
            @Override
            public void onChannelConfirm(String deviceId, ServiceName serviceName,
                    int channelId, ConfirmInfo confirmInfo) {
                if (SameAccountConfirmUtils.isConfirmForAndroidSameApp(
                        ChannelReceiverService.this, confirmInfo)) {
                    mChannelManager.confirmChannel(channelId, ConfirmStatus.ACCEPT);
                } else {
                    mChannelManager.confirmChannel(channelId, ConfirmStatus.REFUSE);
                }
            }

            @Override
            public void onChannelCreateSuccess(@NonNull Channel channel) {
                mChannel = channel;
                Log.i(TAG, "Channel created from: " + channel.getDeviceId());
            }

            @Override
            public void onChannelCreateFailed(@NonNull ServiceName serviceName,
                    int channelId, int errorCode) {
                Log.e(TAG, "Channel failed: " + errorCode);
            }

            @Override
            public void onChannelReceive(@NonNull Channel channel, @NonNull Packet packet) {
                if (packet.getPacketType() == PacketType.FILE) {
                    File saveFile = new File(getFilesDir(), packet.getFilename());
                    packet.asFile(saveFile);
                    Log.i(TAG, "Receiving file: " + packet.getFilename());
                } else if (packet.getPacketType() == PacketType.BYTES) {
                    Log.i(TAG, "Received: " + new String(packet.asBytes()));
                }
            }

            @Override
            public void onChannelTransferProgressUpdate(@NonNull Channel channel,
                    @NonNull Packet packet, PacketTransferProgress progress) {
                if (progress.getTransferState() == PacketTransferState.SUCCEEDED) {
                    Log.i(TAG, "Transfer complete");
                }
            }

            @Override
            public void onChannelRelease(@NonNull Channel channel, int code) {
                Log.i(TAG, "Channel released");
                mChannel = null;
            }
        }, getMainExecutor());
    }
}
```

## Best Practices

1. **Register listener immediately** - Connection initiator has timeout; delays cause failure
2. **Use switches** - Always provide user control to enable/disable static configuration
3. **Transition to foreground** - For long operations, start a foreground service after wake-up
4. **Handle timeouts** - Implement retry logic for connection failures
5. **No keep-alive** - Static config only wakes processes; implement keep-alive separately if needed
6. **Don't mix static and dynamic** - Choose one approach per service to avoid conflicts

## Troubleshooting

### Connection Request Not Received

1. Verify `notifyConnect="true"` in XML config
2. Check `BIND_CONTINUITY_SERVICE_INTERNAL` permission
3. Verify service is enabled (not disabled via `setComponentEnabledSetting`)
4. Check enable switch value

### Channel Creation Fails After Wake-up

1. Register `ChannelListener` immediately in `onNotify()`
2. Don't perform heavy initialization before registering
3. Check connection timeout on sender side
4. Verify `ServiceName` matches between sender and receiver

### Process Unbinds Too Quickly

- Auto-unbind occurs after 10s of no callbacks
- For long operations, transition to foreground service
- Keep channel active with periodic data exchange
