---
name: tianqin-channel
description: Comprehensive documentation for Xiaomi Tianqin-Lyra (天琴) Channel SDK (com.xiaomi.continuity.channel.ContinuityChannelManager). Use when working with Tianqin transmission channels, data transfer, cross-device communication, static channel activation (静态传输通道激活/拉起), ContinuityListenerService, or when the user mentions ContinuityChannelManager, ChannelListener, Channel, Packet, createChannel, registerChannelListener, StaticConfig, ACTION_REQUEST_CONNECTION, or any Tianqin-Lyra channel APIs. Covers channel creation, data sending/receiving, file transfer, static configuration, and all channel data types.
---

# Tianqin-Lyra Channel SDK

Comprehensive guidance for using the Xiaomi Tianqin-Lyra (天琴) Channel SDK for cross-device data transmission.

## Overview

The Tianqin-Lyra Channel SDK (`com.xiaomi.continuity.channel.ContinuityChannelManager`) enables secure data transmission channels between trusted Xiaomi devices. It provides:

- Bidirectional data transmission channels
- Multiple connection mediums (BLE, WLAN, P2P, Bluetooth)
- File and message transfer with progress tracking
- Channel confirmation and security verification
- Automatic medium selection based on conditions
- **Static channel activation** (process wake-up on connection request)

## Prerequisites

### Gradle Configuration

Add Xiaomi maven repositories to your project-level `build.gradle`:

```groovy
repositories {
    maven { url "https://pkgs.d.xiaomi.net:443/artifactory/maven-release-virtual/" }
    maven { url "https://pkgs.d.xiaomi.net:443/artifactory/maven-remote-virtual/" }
    maven { url "https://pkgs.d.xiaomi.net:443/artifactory/maven-snapshot-virtual/" }
}
```

Add the SDK dependency:

```groovy
dependencies {
    implementation "com.xiaomi.continuity:sdk:5.0.131.10.0616156"
}
```

### Permissions

```xml
<uses-permission android:name="android.permission.INTERNET" />
<!-- For static channel activation -->
<uses-permission android:name="com.xiaomi.permission.BIND_CONTINUITY_SERVICE" />
<uses-permission android:name="com.xiaomi.permission.BIND_CONTINUITY_SERVICE_INTERNAL" />
```

## Quick Start

### Server Side (Receiver)

```java
ContinuityChannelManager channelManager = ContinuityChannelManager.getInstance(context);

// 1. Register channel listener BEFORE client connects
ServiceName serviceName = new ServiceName(getPackageName(), "myService");
ServerChannelOptions options = new ServerChannelOptions.Builder()
    .setTrustLevel(TrustLevel.SAME_ACCOUNT)
    .build();

channelManager.registerChannelListener(serviceName, options, new ChannelListener() {
    @Override
    public void onChannelConfirm(String deviceId, ServiceName serviceName,
            int channelId, ConfirmInfo confirmInfo) {
        // Verify and confirm channel
        if (SameAccountConfirmUtils.isConfirmForAndroidSameApp(context, confirmInfo)) {
            channelManager.confirmChannel(channelId, ConfirmStatus.ACCEPT);
        } else {
            channelManager.confirmChannel(channelId, ConfirmStatus.REFUSE);
        }
    }

    @Override
    public void onChannelCreateSuccess(@NonNull Channel channel) {
        // Channel ready for data transfer
    }

    @Override
    public void onChannelCreateFailed(@NonNull ServiceName serviceName,
            int channelId, int errorCode) {
        // Handle failure
    }

    @Override
    public void onChannelReceive(@NonNull Channel channel, @NonNull Packet packet) {
        if (packet.getPacketType() == PacketType.BYTES) {
            byte[] data = packet.asBytes();
        } else if (packet.getPacketType() == PacketType.FILE) {
            packet.asFile(new File(getFilesDir(), packet.getFilename()));
        }
    }

    @Override
    public void onChannelRelease(@NonNull Channel channel, int code) {
        // Channel closed
    }
}, getMainExecutor());
```

### Client Side (Sender)

```java
ContinuityChannelManager channelManager = ContinuityChannelManager.getInstance(context);

// Create channel to target device
ServiceName serviceName = new ServiceName("com.target.app", "myService");
ClientChannelOptions options = new ClientChannelOptions.Builder()
    .setConnectMediumType(ConnectMediumType.NONE) // Auto-select
    .setTrustLevel(TrustLevel.SAME_ACCOUNT)
    .setTimeout(10000)
    .build();

int channelId = channelManager.createChannel(deviceId, serviceName, options,
    new ChannelListener() {
        @Override
        public void onChannelConfirm(String deviceId, ServiceName serviceName,
                int channelId, ConfirmInfo confirmInfo) {
            channelManager.confirmChannel(channelId, ConfirmStatus.ACCEPT);
        }

        @Override
        public void onChannelCreateSuccess(@NonNull Channel channel) {
            // Send data
            channel.send(Packet.fromBytes("Hello".getBytes()));
        }

        @Override
        public void onChannelCreateFailed(@NonNull ServiceName serviceName,
                int channelId, int errorCode) {
            // Handle failure
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
```

## Connection Medium Types

| Type | Characteristics | Max Message Size | Use Case |
|------|-----------------|------------------|----------|
| `NONE` | Auto-select best medium | - | Default choice |
| `BLE` | Low power, slow (~200kbps), <10m | 64KB-128B | Phone-TV |
| `BLUETOOTH` | Low power, slow (~2000kbps), <10m | 64KB-128B | Near-field |
| `WLAN` | Fast (300-600Mbps), same router required | 64KB-128B (msg), unlimited (file) | Audio streaming |
| `P2P` | Fast (600-900Mbps), no router needed, <20m | 64KB-128B (msg), unlimited (file) | Video streaming |
| `REMOTE` | Cloud relay, unlimited distance, slow (~2s) | - | Remote connection (3.0+) |

## Trust Levels

| Level | Description |
|-------|-------------|
| `SAME_ACCOUNT` | Same Xiaomi account required |
| `TRUST_GROUP` | Same account or bound devices |
| `EVERY_ONE` | Any device (requires user confirmation) |

## Data Transfer

### Send Bytes

```java
channel.send(Packet.fromBytes(data));
```

### Send File with Progress

```java
Packet packet = Packet.fromFile(new File("/path/to/file.txt"), "tag");
channel.send(packet, (pkt, progress) -> {
    switch (progress.getTransferState()) {
        case PacketTransferState.SUCCEEDED:
            // Complete
            break;
        case PacketTransferState.IN_PROGRESS:
            float percent = (float) progress.getTransferredLength() / progress.getTotalLength();
            break;
        case PacketTransferState.FAILED:
        case PacketTransferState.CANCELLED:
            // Error
            break;
    }
}, getMainExecutor());
```

### Receive Data

```java
@Override
public void onChannelReceive(@NonNull Channel channel, @NonNull Packet packet) {
    if (packet.getPacketType() == PacketType.BYTES) {
        byte[] bytes = packet.asBytes();
    } else if (packet.getPacketType() == PacketType.FILE) {
        packet.asFile(new File(getFilesDir(), packet.getFilename()));
    }
}
```

### Cancel Transfer

```java
packet.discard();
```

## Channel Confirmation Best Practices

Always verify the connecting app before accepting:

```java
@Override
public void onChannelConfirm(String deviceId, ServiceName serviceName,
        int channelId, ConfirmInfo confirmInfo) {
    // Same account, same app signature
    if (SameAccountConfirmUtils.isConfirmForAndroidSameApp(context, confirmInfo)) {
        channelManager.confirmChannel(channelId, ConfirmStatus.ACCEPT);
        return;
    }

    // Cross-platform (PC) - verify package and signature
    HashMap<String, String> allowedApps = new HashMap<>();
    allowedApps.put("com.example.pcapp", "signature_hash");
    if (SameAccountConfirmUtils.isConfirmForApp(confirmInfo, allowedApps)) {
        channelManager.confirmChannel(channelId, ConfirmStatus.ACCEPT);
        return;
    }

    // Unknown - reject or show user confirmation dialog
    channelManager.confirmChannel(channelId, ConfirmStatus.REFUSE);
}
```

## Static Channel Activation (静态传输通道激活)

Static configuration allows your app to receive channel connection requests without running. When a remote device initiates a connection, your process is woken via `bindService`.

### Quick Setup

1. Create Service extending `ContinuityListenerService`:

```java
public class ContinuitySampleService extends ContinuityListenerService {
    @Override
    public void onNotify(@NonNull Intent intent) {
        if (StaticConfig.ACTION_REQUEST_CONNECTION.equals(intent.getAction())) {
            ServiceName serviceName = intent.getExtras()
                .getParcelable(StaticConfig.EXTRA_SERVICE_NAME);
            // Immediately register channel listener to receive connection
            ContinuityChannelManager.getInstance(this)
                .registerChannelListener(serviceName, options, listener, executor);
        }
    }
}
```

2. Configure in AndroidManifest.xml:

```xml
<service
    android:name=".ContinuitySampleService"
    android:exported="true"
    android:permission="com.xiaomi.permission.BIND_CONTINUITY_LISTENER_SERVICE">
    <intent-filter>
        <action android:name="com.xiaomi.continuity.action.STATIC_CONFIG_ACTION" />
    </intent-filter>
    <meta-data android:name="static_networking_service_list"
        android:resource="@xml/networking_service_list" />
</service>
```

3. Create res/xml/networking_service_list.xml with `notifyConnect="true"`:

```xml
<networking_service_list>
    <service
        serviceName="myChannelService"
        serviceData="[1,2]"
        notifyConnect="true"
        trustLevel="sameAccount" />
</networking_service_list>
```

**Key Points:**
- `notifyConnect="true"` enables process wake-up on connection request
- Requires `BIND_CONTINUITY_SERVICE_INTERNAL` permission
- Register `ChannelListener` immediately in `onNotify()` - connection has timeout
- Auto-unbinds after 10s of no callbacks

For complete static configuration options, see **[Static Channel Activation](references/static-channel.md)**.

## Cleanup

```java
@Override
protected void onDestroy() {
    super.onDestroy();
    channelManager.destroyChannel(channelId);
    channelManager.unregisterChannelListener(serviceName);
    channelManager.unregisterDeathCallback(deathCallback);
    channelManager.unbindService();
}
```

## Detailed Documentation

- **[API Reference](references/api-reference.md)**: Complete interface documentation, all methods, parameters, callbacks, and data types
- **[Code Examples](references/examples.md)**: File transfer, progress tracking, and common patterns
- **[Static Channel Activation](references/static-channel.md)**: Static configuration for process wake-up on connection request

## Version Notes

- **2.0+**: Large data support with automatic fragmentation (`hasFragmentSupport()`)
- **3.0+**: `createChannelV2` with custom user data, `REMOTE` connection type, shared memory support
- **3.1+**: `confirmChannelV2` with server-to-client user data

## Troubleshooting

### Channel Creation Failed

1. Ensure server registered listener BEFORE client connects
2. Verify ServiceName matches on both ends
3. Check TrustLevel compatibility
4. Verify network/Bluetooth connectivity

### Data Transfer Timeout

- WLAN/P2P default: 30s
- BLE/Bluetooth default: 10s
- Implement custom timeout logic for large transfers

### P2P Limitations

- Does not support multi-device connections simultaneously
- Use P2P lock for conflict management
