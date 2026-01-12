---
name: tianqin-lyra-networking
description: Comprehensive documentation for Xiaomi Tianqin-Lyra (天琴) Networking SDK (com.xiaomi.continuity.networking.NetworkingManager). Use when working with Tianqin device discovery, service registration, cross-device networking, static service activation (静态服务激活/拉起), ContinuityListenerService, or when the user mentions NetworkingManager, ServiceListener, TrustedDeviceInfo, BusinessServiceInfo, StaticConfig, or any Tianqin-Lyra networking APIs. Covers device discovery, service publishing, static configuration, callbacks, filters, and all data types.
---

# Tianqin-Lyra Networking SDK

Comprehensive guidance for using the Xiaomi Tianqin-Lyra (天琴) Networking SDK for cross-device discovery and communication.

## Overview

The Tianqin-Lyra Networking SDK (`com.xiaomi.continuity.networking.NetworkingManager`) enables automatic device discovery and service registration across trusted Xiaomi devices. It provides:

- Automatic device discovery via BLE and WLAN
- Service registration and discovery
- Real-time device online/offline notifications
- Device property queries
- Cross-platform support (Android, iOS, Windows, etc.)
- **Static service activation** (process wake-up without running)

## Prerequisites

### Gradle Configuration

Add Xiaomi maven repositories to your project-level `build.gradle`:

```groovy
repositories {
    // ... other repositories
    maven { url "https://pkgs.d.xiaomi.net:443/artifactory/maven-release-virtual/" }
    maven { url "https://pkgs.d.xiaomi.net:443/artifactory/maven-remote-virtual/" }
    maven { url "https://pkgs.d.xiaomi.net:443/artifactory/maven-snapshot-virtual/" }
}
```

Add the SDK dependency to your module-level `build.gradle`:

```groovy
dependencies {
    implementation "com.xiaomi.continuity:sdk:5.0.131.10.0616156"
}
```

After modifying gradle files, sync gradle to download the SDK dependencies.

### Permissions

Add required permission to `AndroidManifest.xml`:

```xml
<!-- Basic permission for static config operations -->
<uses-permission android:name="com.xiaomi.permission.BIND_CONTINUITY_SERVICE" />
<!-- Required for dynamic addServiceInfo() and process wake-up (requires platform signature or system app) -->
<uses-permission android:name="com.xiaomi.permission.BIND_CONTINUITY_SERVICE_INTERNAL" />
```

### Key Imports

```java
// Core classes - note the correct package names
import com.xiaomi.continuity.ServiceName;  // NOT com.xiaomi.continuity.networking.ServiceName
import com.xiaomi.continuity.ContinuityListenerService;  // NOT com.xiaomi.continuity.staticconfig.ContinuityListenerService

// Networking classes
import com.xiaomi.continuity.networking.NetworkingManager;
import com.xiaomi.continuity.networking.ServiceListener;
import com.xiaomi.continuity.networking.TrustedDeviceInfo;
import com.xiaomi.continuity.networking.BusinessServiceInfo;
import com.xiaomi.continuity.networking.ServiceFilter;
```

## Quick Start

### Basic Setup

```java
// 1. Get NetworkingManager instance
NetworkingManager manager = NetworkingManager.getInstance(context);

// 2. Register death callback for service recovery
manager.registerDeathCallback(() -> {
    // Re-initialize and re-register listeners
});

// 3. Register service listener
manager.addServiceListener(filter, new ServiceListener() {
    @Override
    public void onServiceOnline(BusinessServiceInfo serviceInfo, TrustedDeviceInfo deviceInfo) {
        // Handle device online
    }

    @Override
    public void onServiceOffline(BusinessServiceInfo serviceInfo,
            TrustedDeviceInfo deviceInfo, int reason) {
        // Handle device offline
    }

    @Override
    public void onDeviceChanged(TrustedDeviceInfo deviceInfo) {
        // Handle device property changes
    }

    @Override
    public void onServiceChanged(BusinessServiceInfo serviceInfo, TrustedDeviceInfo deviceInfo) {
        // Handle service data changes
    }
});

// 4. Publish your service
BusinessServiceInfo serviceInfo = new BusinessServiceInfo();
serviceInfo.setServiceName("myService");
serviceInfo.setServiceData(capabilityData); // Max 32 bytes
manager.addServiceInfo(serviceInfo);
```

## Static Service Activation (静态服务激活)

Static configuration allows networking features without starting the app process. The process is woken via `bindService` when events occur.

### Quick Setup

1. Create Service extending `ContinuityListenerService`:

```java
public class ContinuitySampleService extends ContinuityListenerService {
    @Override
    public void onNotify(@NonNull Intent intent) {
        String action = intent.getAction();
        if (StaticConfig.ACTION_SERVICE_ONLINE.equals(action)) {
            // Device came online - switch to dynamic API
            TrustedDeviceInfo device = intent.getExtras()
                .getParcelable(StaticConfig.EXTRA_NETWORKING_DEVICE);
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
    <meta-data android:name="static_networking_service_filters"
        android:resource="@xml/networking_service_filter" />
</service>
```

3. Create res/xml/networking_service_list.xml (publish service):

```xml
<networking_service_list>
    <service serviceName="myService" serviceData="[1,2]" notifyConnect="true" />
</networking_service_list>
```

4. Create res/xml/networking_service_filter.xml (discover services):

```xml
<networking_service_filters>
    <filter serviceName="targetService" deviceTypes="phone|pad" />
</networking_service_filters>
```

For complete static configuration options, see **[Static Service Activation](references/static-service.md)**.

## Common Workflows

### Workflow 1: Discover Devices with Specific Service

```java
// Create filter for specific service
ServiceFilter filter = new ServiceFilter();
filter.setServiceFilter(new ServiceName("com.example.app", "targetService"));

// Optionally filter by device type
List<Integer> deviceTypes = Arrays.asList(
    TrustedDeviceInfo.DEVICE_TYPE_PHONE,
    TrustedDeviceInfo.DEVICE_TYPE_PAD
);
filter.setDeviceTypeFilter(deviceTypes);

// Register listener
manager.addServiceListener(filter, listener);
```

### Workflow 2: Query Current Device List

```java
// Get all online devices
List<TrustedDeviceInfo> devices = manager.getTrustedDeviceList();

for (TrustedDeviceInfo device : devices) {
    // Get device services
    List<BusinessServiceInfo> services = manager.getServiceInfoList(device.getDeviceId());

    // Check specific service
    BusinessServiceInfo service = manager.getServiceInfo(
        device.getDeviceId(),
        new ServiceName("com.example.app", "myService")
    );
}
```

### Workflow 3: Publish and Update Service

```java
// Publish service
BusinessServiceInfo serviceInfo = new BusinessServiceInfo();
serviceInfo.setServiceName("myService");

// Encode capabilities in service data (max 32 bytes)
byte[] data = new byte[4];
data[0] = 0x01; // Feature flags
data[1] = 0x02; // Version info
serviceInfo.setServiceData(data);

manager.addServiceInfo(serviceInfo);

// Update service data later
serviceInfo.setServiceData(newData);
manager.addServiceInfo(serviceInfo); // Overwrites existing
```

### Workflow 4: Accelerate Device Discovery

```java
// When you need faster device discovery/removal
manager.updateNetworkingPolicy(
    NetworkingManager.UPDATE_POLICY_USER_DEFAULT,
    "com.example.app"
);

// For Apple device discovery (3.0+)
manager.updateNetworkingPolicy(
    NetworkingManager.UPDATE_POLICY_APPLE_BLE_NETWORKING,
    "com.example.app"
);
```

### Workflow 5: Query Device Properties

```java
String deviceId = device.getDeviceId();

// String properties
String ip = manager.getStringProperty(deviceId, PropertyType.PropIpAddr.toInteger());
String productId = manager.getStringProperty(deviceId, PropertyType.PropProductID.toInteger());
String deviceName = manager.getStringProperty(deviceId, PropertyType.PropDeviceName.toInteger());

// Int properties
int osType = manager.getIntProperty(deviceId, PropertyType.PropOSType.toInteger());
int supportsP2P = manager.getIntProperty(deviceId, PropertyType.PropSupportP2P.toInteger());
```

## Key Concepts

### Trusted Devices

Devices are considered trusted if they meet one of:
1. Same Xiaomi account
2. Point-to-point binding (planned feature)

### Auto-Networking Conditions

Devices automatically network when:
1. Devices are trusted
2. Bluetooth is enabled and devices are in range, OR devices are on the same LAN

### Performance Characteristics

- **Device online time**: 1-5 seconds (varies by conditions)
- **Device offline time**: 10-60 seconds (varies by conditions)
- Use `updateNetworkingPolicy()` to accelerate when needed

### Service Data Guidelines

- **Max size**: 32 bytes
- **Appropriate content**: Capability flags, version info, feature toggles
- **Avoid**: Volatile data like IP addresses, frequently changing values
- **Reason**: Service data changes trigger network synchronization (expensive)

### Service Name Guidelines

- **Max size**: 12 bytes recommended
- **Format**: Alphanumeric only, avoid special characters (,/.#:)
- **Uniqueness**: Must be globally unique across apps

### Device Type Constants

Use the correct device type constants from `TrustedDeviceInfo`:
- **Car**: Use `DEVICE_TYPE_MI_AUTOMOTIVE` (NOT `DEVICE_TYPE_CAR`)
- **Speaker**: Use `DEVICE_TYPE_SOUND` (NOT `DEVICE_TYPE_SPEAKER`)

## Important Notes

### Callback Timing

The order of `onChannelCreateSuccess` and `onServiceOnline` callbacks is not guaranteed. When a device is connected, it may not yet be networked. Use query methods to get device info if needed.

### Thread Safety

ServiceListener callbacks may arrive on different threads. Use `runOnUiThread()` for UI updates.

### Cleanup

Always cleanup in `onDestroy()`:
```java
manager.removeServiceListener(listener);
manager.removeServiceInfo(serviceInfo);
manager.unregisterDeathCallback(deathCallback);
manager.unbindService();
```

## Detailed Documentation

For complete API reference, data types, and code examples:

- **[API Reference](references/api-reference.md)**: Complete interface documentation, all methods, parameters, return values, callbacks, and data types
- **[Code Examples](references/examples.md)**: Complete sample application and common usage patterns
- **[Static Service Activation](references/static-service.md)**: Static configuration for process wake-up without running

## Version Notes

Features marked with "3.0+" require Tianqin-Lyra SDK version 3.0 or later:
- `updateNetworkingPolicy()` with DeviceFilter parameter
- `addServiceInfo()` with ServiceInfoOption parameter
- `getTrustedDeviceList()` async variant
- Additional PropertyType values (PropWifiSwitch, PropBleSwitch, etc.)
- Apple BLE networking policies

## Troubleshooting

### Devices Not Appearing

1. Verify devices are trusted (same account)
2. Check Bluetooth/WiFi is enabled
3. Verify devices are in range or on same LAN
4. Try `updateNetworkingPolicy()` to accelerate discovery
5. Check ServiceFilter is not too restrictive

### Service Not Publishing

1. Verify service name is unique and follows guidelines
2. Check service data is ≤32 bytes
3. Verify required permissions are granted
4. Check return value from `addServiceInfo()` (0 = success)

### Slow Device Discovery

1. Use `updateNetworkingPolicy()` with appropriate policy
2. Consider device state (screen on/off affects timing)
3. Check network conditions (BLE range, WiFi connectivity)

### Service Crashes

1. Always register death callback
2. Re-initialize manager and re-register listeners in callback
3. Re-publish services after recovery
