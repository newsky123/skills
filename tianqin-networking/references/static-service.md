# Static Service Activation (静态服务激活)

## Overview

Static configuration allows apps to use networking features without starting the process. Callbacks are delivered via Service AIDL interface. If the process is not running, it will be started and receive callbacks.

**Key Points:**
- Complements dynamic API with process wake-up capability
- Does NOT provide keep-alive functionality
- Process is started via `bindService`, auto-unbinds after 10s of no callbacks
- After wake-up, switch to dynamic API for full functionality

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
    <!-- Static service publishing -->
    <meta-data
        android:name="static_networking_service_list"
        android:resource="@xml/networking_service_list" />
    <!-- Static service discovery -->
    <meta-data
        android:name="static_networking_service_filters"
        android:resource="@xml/networking_service_filter" />
</service>
```

### Service Implementation

```java
public class ContinuitySampleService extends ContinuityListenerService {
    @MainThread
    public void onNotify(@NonNull Intent intent) {
        String action = intent.getAction();
        // Handle different actions based on configuration
    }
}
```

### Enable/Disable Static Configuration

```java
// Enable
getPackageManager().setComponentEnabledSetting(componentName,
    PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
    PackageManager.DONT_KILL_APP);

// Disable
getPackageManager().setComponentEnabledSetting(componentName,
    PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
    PackageManager.DONT_KILL_APP);
```

## Enable Switch Control

Control static component via Settings URI. Supports `()`, `&` (use `&amp;` in XML), `|` operators.

| Method | Configuration |
|--------|---------------|
| Default (Xiaomi connectivity switch) | No config needed, or: `{content://settings/secure/pref_key_connectivity_service_state}` |
| Custom setting | `{content://settings/secure/xxx_xxx}` |
| Always enabled | `1` |
| Logical combination | `{content://settings/global/Enabled1}&amp;{content://settings/global/Enabled2}` |

```xml
<meta-data android:name="static_enable_switch"
    android:value="{content://settings/secure/pref_key_connectivity_service_state}" />
```

## Runtime Configuration Modification

Store dynamic settings in Settings URI. Content format is JSON array `[]`.

```xml
<!-- Merge {} URI content with [] static values -->
<service
    serviceName="sampleApp"
    serviceData="{content://settings/system/sampleApp}[2,3,5]"
    needAddService="true"
    notifyConnect="true" />
```

If `content://settings/system/sampleApp` contains `[1,2,3]`, merged result is `[1,2,3,2,3,5]`.

## Static Service Publishing

### XML Configuration (res/xml/networking_service_list.xml)

```xml
<networking_service_list>
    <service
        serviceName="sampleApp"
        serviceData="[2]"
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
| `notifyConnect` | Wake process on connection request (requires INTERNAL permission) | No |
| `needAddService` | Publish service (default: true). Set false for connection-only | No |
| `trustLevel` | Allowed trust levels: `sameAccount`, `trustGroup`, `everyOne` | No (2.2+) |

### P2P Lock Options (2.2+)

```xml
<service serviceName="sampleApp">
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

### Equivalent Dynamic API

```java
BusinessServiceInfo serviceInfo = new BusinessServiceInfo();
serviceInfo.setServiceName("sampleApp");
BitSet bitSet = new BitSet();
bitSet.set(0, true); // Feature 1
bitSet.set(1, true); // Feature 2
// bitSet.toByteArray() = [3]
serviceInfo.setServiceData(bitSet.toByteArray());
mNetworkingManager.addServiceInfo(serviceInfo);
```

## Connection Request Activation

When `notifyConnect="true"`, process wakes on incoming connection requests.

**Action:** `StaticConfig.ACTION_REQUEST_CONNECTION` (`com.xiaomi.continuity.action.REQUEST_CONNECTION`)

**Extras:**

| Name | Value | Type |
|------|-------|------|
| `EXTRA_SERVICE_NAME` | `com.xiaomi.continuity.EXTRA_SERVICE_NAME` | `ServiceName` |

```java
public class ContinuitySampleService extends ContinuityListenerService {
    @Override
    public void onNotify(@NonNull Intent intent) {
        if (StaticConfig.ACTION_REQUEST_CONNECTION.equals(intent.getAction())) {
            ServiceName serviceName = intent.getExtras()
                .getParcelable(StaticConfig.EXTRA_SERVICE_NAME);
            // Immediately call ContinuityChannelManager.registerChannelListener()
            // to receive onChannelConfirm and onChannelCreate callbacks
        }
    }
}
```

## Static Service Discovery

### XML Configuration (res/xml/networking_service_filter.xml)

```xml
<networking_service_filters>
    <filter
        serviceName="sampleApp"
        packageName="com.xiaomi.continuity.sample"
        deviceTypes="phone|pad|tv|pc|vela_wear|vela_sound|mi_automotive"
        trustedTypes="sameAccount"
        listenerTypes="serviceOnline|serviceOffline|serviceChanged|deviceChanged" />
</networking_service_filters>
```

### Filter Attributes

| Attribute | Description | Required |
|-----------|-------------|----------|
| `serviceName` | Service name to discover | Yes |
| `packageName` | Package name filter (all packages if not set) | No |
| `deviceTypes` | Device types: `phone\|pad\|tv\|pc\|vela_wear\|vela_sound\|mi_automotive` | No |
| `trustedTypes` | Trust relationship: `sameAccount` | No |
| `listenerTypes` | Events: `serviceOnline\|serviceOffline\|serviceChanged\|deviceChanged` (default: serviceOnline) | No (0.11.0+) |

### Actions

| Action | Constant |
|--------|----------|
| Service Online | `StaticConfig.ACTION_SERVICE_ONLINE` (`com.xiaomi.continuity.action.SERVICE_ONLINE`) |
| Service Offline | `StaticConfig.ACTION_SERVICE_OFFLINE` (`com.xiaomi.continuity.action.SERVICE_OFFLINE`) |
| Service Changed | `StaticConfig.ACTION_SERVICE_CHANGED` (`com.xiaomi.continuity.action.SERVICE_CHANGED`) |
| Device Changed | `StaticConfig.ACTION_DEVICE_CHANGED` (`com.xiaomi.continuity.action.DEVICE_CHANGED`) |

### Extras

| Name | Value | Type |
|------|-------|------|
| `EXTRA_NETWORKING_SERVICE` | `com.xiaomi.continuity.EXTRA_SERVICE_INFO` | `BusinessServiceInfo` |
| `EXTRA_NETWORKING_DEVICE` | `com.xiaomi.continuity.EXTRA_DEVICE_INFO` | `TrustedDeviceInfo` |
| `EXTRA_REASON` | `com.xiaomi.continuity.EXTRA_REASON` | `int` |

### Handler Example

```java
public class ContinuitySampleService extends ContinuityListenerService {
    @Override
    public void onNotify(@NonNull Intent intent) {
        String action = intent.getAction();
        Bundle ext = intent.getExtras();

        if (StaticConfig.ACTION_SERVICE_ONLINE.equals(action)) {
            TrustedDeviceInfo device = ext.getParcelable(StaticConfig.EXTRA_NETWORKING_DEVICE);
            BusinessServiceInfo service = ext.getParcelable(StaticConfig.EXTRA_NETWORKING_SERVICE);
            // Recommended: call NetworkingManager.addServiceListener() for subsequent callbacks

        } else if (StaticConfig.ACTION_SERVICE_OFFLINE.equals(action)) {
            TrustedDeviceInfo device = ext.getParcelable(StaticConfig.EXTRA_NETWORKING_DEVICE);
            BusinessServiceInfo service = ext.getParcelable(StaticConfig.EXTRA_NETWORKING_SERVICE);
            int reason = ext.getInt(StaticConfig.EXTRA_REASON, ServiceListener.OFFLINE_OTHER);

        } else if (StaticConfig.ACTION_SERVICE_CHANGED.equals(action)) {
            TrustedDeviceInfo device = ext.getParcelable(StaticConfig.EXTRA_NETWORKING_DEVICE);
            BusinessServiceInfo service = ext.getParcelable(StaticConfig.EXTRA_NETWORKING_SERVICE);

        } else if (StaticConfig.ACTION_DEVICE_CHANGED.equals(action)) {
            TrustedDeviceInfo device = ext.getParcelable(StaticConfig.EXTRA_NETWORKING_DEVICE);
        }
    }
}
```

## Best Practices

1. **Use switches** - Always provide user control to enable/disable static configuration
2. **Transition to dynamic API** - After process wake-up, switch to dynamic API for full functionality
3. **Don't mix static and dynamic publishing** - Choose one approach per service
4. **Handle timeouts** - Connection requests have timeouts; register listeners immediately after wake-up
5. **No keep-alive** - Static config only wakes processes; implement keep-alive separately if needed
