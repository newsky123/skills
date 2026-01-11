# Tianqin-Lyra Networking Code Examples

## Complete Sample Application

This is a complete Android Activity demonstrating all major features of the Tianqin-Lyra Networking SDK.

```java
package com.xiaomi.continuity.sample;

import android.os.Build;
import android.os.Bundle;
import android.text.Html;
import android.util.Log;
import android.view.View;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

import com.xiaomi.continuity.ServiceName;
import com.xiaomi.continuity.networking.BusinessServiceInfo;
import com.xiaomi.continuity.networking.NetworkingManager;
import com.xiaomi.continuity.networking.OsType;
import com.xiaomi.continuity.networking.PropertyType;
import com.xiaomi.continuity.networking.ServiceFilter;
import com.xiaomi.continuity.networking.ServiceListener;
import com.xiaomi.continuity.networking.TrustedDeviceInfo;

import androidx.appcompat.app.AppCompatActivity;

public class NetworkingSample extends AppCompatActivity {
    private static final String TAG = "NetworkingSample";

    private static final int LEVEL_INFO = 0;
    private static final int LEVEL_ERROR = 1;
    private static final int LEVEL_WARNING = 2;
    private static final int LEVEL_VERBOSE = 3;
    private static final int LEVEL_DEBUG = 4;

    private NetworkingManager mNetworkingManager;
    private ServiceListener mTrustedDeviceListener;
    private TextView mTextView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_networking);
        mTextView = findViewById(R.id.textLog);

        // Initialize NetworkingManager
        mNetworkingManager = NetworkingManager.getInstance(getApplicationContext());

        // Register death callback for service recovery
        mNetworkingManager.registerDeathCallback(() -> {
            addLog(LEVEL_ERROR, "BinderDied");
        });

        // Create service listener
        mTrustedDeviceListener = new ServiceListener() {
            @Override
            public void onServiceOnline(BusinessServiceInfo serviceInfo, TrustedDeviceInfo deviceInfo) {
                runOnUiThread(() -> {
                    addLog(LEVEL_INFO, "onServiceOnline: ",
                        "service:" + serviceInfo + ",deviceInfo:" + deviceInfo);
                });
            }

            @Override
            public void onServiceOffline(BusinessServiceInfo serviceInfo,
                    TrustedDeviceInfo deviceInfo, int reason) {
                runOnUiThread(() -> {
                    addLog(LEVEL_INFO, "onServiceOffline: ",
                        "service:" + serviceInfo + ",deviceInfo:" + deviceInfo);
                });
            }

            @Override
            public void onDeviceChanged(TrustedDeviceInfo deviceInfo) {
                runOnUiThread(() -> {
                    addLog(LEVEL_INFO, "onDeviceChanged: ", "deviceInfo:" + deviceInfo);
                });
            }

            @Override
            public void onServiceChanged(BusinessServiceInfo serviceInfo,
                    TrustedDeviceInfo deviceInfo) {
                runOnUiThread(() -> {
                    addLog(LEVEL_INFO, "onServiceChanged: ",
                        "service:" + serviceInfo + ",deviceInfo:" + deviceInfo);
                });
            }
        };
    }

    public void onClick(View view) {
        switch (view.getId()) {
            case R.id.testRegister:
                testRegister();
                break;
            case R.id.testUnregister:
                testUnregister();
                break;
            case R.id.testGetDevices:
                testGetDevices();
                break;
            case R.id.testUpdatePolicy:
                testUpdatePolicy();
                break;
            case R.id.testClear:
                testClear();
                break;
            case R.id.testAddService:
                testAddService();
                break;
            case R.id.testRemoveService:
                testRemoveService();
                break;
            case R.id.testModifyService:
                testModifyService();
                break;
            case R.id.testGetDeviceProperty:
                testGetDeviceProperty();
                break;
        }
    }

    /**
     * Example: Register service listener with filter
     */
    private void testRegister() {
        ServiceFilter filter = new ServiceFilter();
        filter.setServiceFilter(new ServiceName("com.xiaomi.continuity.sample", "sampleApp"));

        List<Integer> trustedTypeFilter = new ArrayList<>();
        trustedTypeFilter.add(TrustedDeviceInfo.TRUSTED_TYPES_SAME_ACCOUNT);
        filter.setTrustedTypeFilter(trustedTypeFilter);

        int ret = mNetworkingManager.addServiceListener(filter, mTrustedDeviceListener);

        // Alternative: Register without filter to show all services
        // int ret = mNetworkingManager.addServiceListener(null, mTrustedDeviceListener);

        addLog(LEVEL_VERBOSE, "Register ret:" + ret);
    }

    /**
     * Example: Unregister service listener
     */
    private void testUnregister() {
        mNetworkingManager.removeServiceListener(mTrustedDeviceListener);
        addLog(LEVEL_VERBOSE, "Unregister Success");
    }

    /**
     * Example: Update networking policy to accelerate device discovery
     */
    private void testUpdatePolicy() {
        int defaultPolicy = NetworkingManager.UPDATE_POLICY_USER_DEFAULT;
        int ret = mNetworkingManager.updateNetworkingPolicy(defaultPolicy, TAG);
        addLog(LEVEL_VERBOSE, "Update Policy: " + ret);
    }

    /**
     * Example: Add service information
     */
    private void testAddService() {
        BusinessServiceInfo serviceInfo = new BusinessServiceInfo();
        serviceInfo.setServiceName("service" + new Random().nextInt());

        byte[] data = new byte[4];
        new Random().nextBytes(data);
        serviceInfo.setServiceData(data);

        mNetworkingManager.addServiceInfo(serviceInfo);
        addLog(LEVEL_VERBOSE, "SetService:", serviceInfo.toString());
    }

    /**
     * Example: Remove service information
     */
    private void testRemoveService() {
        String localDevId = mNetworkingManager.getLocalDeviceInfo().getDeviceId();
        List<BusinessServiceInfo> serviceList = mNetworkingManager.getServiceInfoList(localDevId);

        if (serviceList.size() > 0) {
            BusinessServiceInfo serviceInfo = serviceList.get(0);
            int ret = mNetworkingManager.removeServiceInfo(serviceInfo);

            if (ret == 0) {
                addLog(LEVEL_VERBOSE, "removeService:", serviceInfo.toString());
            } else {
                Log.w(TAG, "the service does not exist, service:" + serviceInfo);
            }
        }
    }

    /**
     * Example: Modify existing service information
     */
    public void testModifyService() {
        List<BusinessServiceInfo> serviceInfoList = mNetworkingManager.getServiceInfoList(
                mNetworkingManager.getLocalDeviceInfo().getDeviceId());

        if (!serviceInfoList.isEmpty()) {
            BusinessServiceInfo serviceInfo = serviceInfoList.get(0);

            // Update service data
            byte[] data = new byte[4];
            new Random().nextBytes(data);
            serviceInfo.setServiceData(data);

            int ret = mNetworkingManager.addServiceInfo(serviceInfo);
            addLog(LEVEL_INFO, "addServiceInfo", "result:" + ret + ",service:" + serviceInfo);
        }
    }

    /**
     * Example: Get devices and their services
     */
    private void testGetDevices() {
        addLog(LEVEL_VERBOSE, "GetDevices:");

        // Get local device info
        TrustedDeviceInfo dev = mNetworkingManager.getLocalDeviceInfo();
        addLog(LEVEL_DEBUG, "Local Dev: ", dev.toString());

        // Get local device services
        List<BusinessServiceInfo> serviceInfoList =
            mNetworkingManager.getServiceInfoList(dev.getDeviceId());
        addLog(LEVEL_DEBUG, "Local Dev Services: ", serviceInfoList.toString());

        // Get online devices
        List<TrustedDeviceInfo> deviceInfoList = mNetworkingManager.getTrustedDeviceList();
        addLog(LEVEL_DEBUG, "Online Devices: ", deviceInfoList.toString());

        // Get services for each online device
        if (deviceInfoList != null) {
            for (TrustedDeviceInfo device : deviceInfoList) {
                List<BusinessServiceInfo> ser1 =
                    mNetworkingManager.getServiceInfoList(device.getDeviceId());
                addLog(LEVEL_DEBUG, "Online Dev Services: ", ser1.toString());
            }
        }
    }

    /**
     * Example: Get device properties
     */
    public void testGetDeviceProperty() {
        addLog(LEVEL_VERBOSE, "GetDeviceProperty:");

        // Show local device properties
        addLog(LEVEL_DEBUG, "Local Device: ");
        TrustedDeviceInfo dev = mNetworkingManager.getLocalDeviceInfo();
        showDeviceProperty(dev.getDeviceId());

        // Show online devices properties
        List<TrustedDeviceInfo> deviceInfoList = mNetworkingManager.getTrustedDeviceList();
        addLog(LEVEL_DEBUG, "Online Devices: ");

        if (deviceInfoList != null) {
            for (TrustedDeviceInfo device : deviceInfoList) {
                showDeviceProperty(device.getDeviceId());
            }
        }
    }

    /**
     * Example: Query specific service by name
     */
    public void testFilter(View view) {
        List<TrustedDeviceInfo> deviceInfoList = mNetworkingManager.getTrustedDeviceList();

        if (!deviceInfoList.isEmpty()) {
            List<BusinessServiceInfo> serviceInfoList =
                mNetworkingManager.getServiceInfoList(deviceInfoList.get(0).getDeviceId());

            if (!serviceInfoList.isEmpty()) {
                BusinessServiceInfo serviceInfo = serviceInfoList.get(0);
                ServiceName serviceName = new ServiceName(
                    serviceInfo.getPackageName(),
                    serviceInfo.getServiceName()
                );

                BusinessServiceInfo newService = mNetworkingManager.getServiceInfo(
                    deviceInfoList.get(0).getDeviceId(),
                    serviceName
                );

                addLog(LEVEL_INFO, "serviceName", "result:" + newService);
            }
        }
    }

    /**
     * Helper: Show all properties for a device
     */
    private void showDeviceProperty(String devId) {
        String ip = mNetworkingManager.getStringProperty(devId,
            PropertyType.PropIpAddr.toInteger());
        String bt_mac = mNetworkingManager.getStringProperty(devId,
            PropertyType.PropBtAddr.toInteger());
        String p2p_addr = mNetworkingManager.getStringProperty(devId,
            PropertyType.PropP2PAddr.toInteger());
        int supportP2P = mNetworkingManager.getIntProperty(devId,
            PropertyType.PropSupportP2P.toInteger());
        int support_rfcomm = mNetworkingManager.getIntProperty(devId,
            PropertyType.PropSupportRfcomm.toInteger());
        int support_nogroup = mNetworkingManager.getIntProperty(devId,
            PropertyType.PropSupportNogroup.toInteger());
        OsType os = OsType.fromInteger(
            mNetworkingManager.getIntProperty(devId, PropertyType.PropOSType.toInteger())
        );
        String productID = mNetworkingManager.getStringProperty(devId,
            PropertyType.PropProductID.toInteger());
        String LyraVersion = mNetworkingManager.getStringProperty(devId,
            PropertyType.PropLyraVersion.toInteger());

        addLog(LEVEL_DEBUG, "devId: " + devId +
            ", ip=" + ip +
            ", bt_mac=" + bt_mac +
            ", p2p_addr=" + p2p_addr +
            ", supportP2P=" + supportP2P +
            ", support_rfcomm=" + support_rfcomm +
            ", support_nogroup=" + support_nogroup +
            ", productID=" + productID +
            ", LyraVersion=" + LyraVersion +
            ", os=" + os + "<br>");
    }

    /**
     * Helper: Get device services
     */
    private void getDeviceServices(String devId) {
        List<BusinessServiceInfo> serviceInfoList =
            mNetworkingManager.getServiceInfoList(devId);
        addLog(LEVEL_DEBUG, "Dev Services: ", serviceInfoList.toString());
    }

    private void testClear() {
        mTextView.setText("");
    }

    private void addLog(int level, String title) {
        addLog(level, title, null);
    }

    private void addLog(int level, String title, String log) {
        String title_changed;
        switch (level) {
            case LEVEL_INFO:
                title_changed = "<h2><font color='#2E8B57'>" + title + "</font></h2>";
                break;
            case LEVEL_ERROR:
                title_changed = "<h2><font color='#CD5555'>" + title + "</font></h2>";
                break;
            case LEVEL_WARNING:
                title_changed = "<h2><font color='#EEB422'>" + title + "</font></h2>";
                break;
            case LEVEL_VERBOSE:
                title_changed = "<h2><font color='#87CEFF'>" + title + "</font></h2>";
                break;
            default:
                title_changed = "<b><font color='#8B658B'>" + title + "</font></b>";
                break;
        }

        runOnUiThread(() -> {
            if (Build.VERSION.SDK_INT > Build.VERSION_CODES.N) {
                if (log == null) {
                    mTextView.append(Html.fromHtml(title_changed, Html.FROM_HTML_MODE_COMPACT));
                } else {
                    mTextView.append(Html.fromHtml(
                        title_changed + log + "<br>",
                        Html.FROM_HTML_MODE_COMPACT
                    ));
                }
            } else {
                mTextView.append(title + log + "\n");
            }
        });
    }
}
```

## Common Usage Patterns

### Pattern 1: Basic Device Discovery

```java
// Initialize manager
NetworkingManager manager = NetworkingManager.getInstance(context);

// Register listener without filter (discover all devices)
manager.addServiceListener(null, new ServiceListener() {
    @Override
    public void onServiceOnline(BusinessServiceInfo serviceInfo, TrustedDeviceInfo deviceInfo) {
        Log.i(TAG, "Device online: " + deviceInfo.getDeviceName());
    }

    @Override
    public void onServiceOffline(BusinessServiceInfo serviceInfo,
            TrustedDeviceInfo deviceInfo, int reason) {
        Log.i(TAG, "Device offline: " + deviceInfo.getDeviceName());
    }

    @Override
    public void onDeviceChanged(TrustedDeviceInfo deviceInfo) {
        Log.i(TAG, "Device changed: " + deviceInfo.getDeviceName());
    }

    @Override
    public void onServiceChanged(BusinessServiceInfo serviceInfo, TrustedDeviceInfo deviceInfo) {
        Log.i(TAG, "Service changed on: " + deviceInfo.getDeviceName());
    }
});
```

### Pattern 2: Filtered Device Discovery

```java
// Create filter for specific service and device types
ServiceFilter filter = new ServiceFilter();

// Filter by service name
filter.setServiceFilter(new ServiceName("com.example.app", "myService"));

// Filter by device type (only phones and pads)
List<Integer> deviceTypes = new ArrayList<>();
deviceTypes.add(TrustedDeviceInfo.DEVICE_TYPE_PHONE);
deviceTypes.add(TrustedDeviceInfo.DEVICE_TYPE_PAD);
filter.setDeviceTypeFilter(deviceTypes);

// Filter by trust relationship (same account only)
List<Integer> trustedTypes = new ArrayList<>();
trustedTypes.add(TrustedDeviceInfo.TRUSTED_TYPES_SAME_ACCOUNT);
filter.setTrustedTypeFilter(trustedTypes);

// Register with filter
manager.addServiceListener(filter, listener);
```

### Pattern 3: Publishing Service Information

```java
// Create service info
BusinessServiceInfo serviceInfo = new BusinessServiceInfo();
serviceInfo.setServiceName("myService");

// Set service data (max 32 bytes)
byte[] data = new byte[4];
// Encode capability flags or version info
data[0] = 0x01; // Feature flag 1
data[1] = 0x02; // Feature flag 2
data[2] = 0x01; // Version major
data[3] = 0x00; // Version minor
serviceInfo.setServiceData(data);

// Add service (persists even if app is killed)
int result = manager.addServiceInfo(serviceInfo);
if (result == 0) {
    Log.i(TAG, "Service published successfully");
}
```

### Pattern 4: Querying Device List

```java
// Get all online devices
List<TrustedDeviceInfo> devices = manager.getTrustedDeviceList();

for (TrustedDeviceInfo device : devices) {
    Log.i(TAG, "Device: " + device.getDeviceName() +
        " (" + device.getDeviceId() + ")");

    // Check device capabilities
    if (device.hasBle()) {
        Log.i(TAG, "  - Supports BLE networking");
    }
    if (device.hasWlan()) {
        Log.i(TAG, "  - Supports WLAN networking");
    }

    // Get device services
    List<BusinessServiceInfo> services = manager.getServiceInfoList(device.getDeviceId());
    for (BusinessServiceInfo service : services) {
        Log.i(TAG, "  - Service: " + service.getServiceName());
    }
}
```

### Pattern 5: Accelerating Device Discovery

```java
// Use when you need faster device discovery/removal
int policy = NetworkingManager.UPDATE_POLICY_USER_DEFAULT;
int result = manager.updateNetworkingPolicy(policy, "com.example.app");

// For Apple device BLE networking (Android 3.0+)
manager.updateNetworkingPolicy(
    NetworkingManager.UPDATE_POLICY_APPLE_BLE_NETWORKING,
    "com.example.app"
);
```

### Pattern 6: Querying Device Properties

```java
String deviceId = device.getDeviceId();

// Get string properties
String ip = manager.getStringProperty(deviceId, PropertyType.PropIpAddr.toInteger());
String productId = manager.getStringProperty(deviceId, PropertyType.PropProductID.toInteger());
String deviceName = manager.getStringProperty(deviceId, PropertyType.PropDeviceName.toInteger());

// Get int properties
int osType = manager.getIntProperty(deviceId, PropertyType.PropOSType.toInteger());
int supportsP2P = manager.getIntProperty(deviceId, PropertyType.PropSupportP2P.toInteger());

Log.i(TAG, "Device: " + deviceName +
    ", IP: " + ip +
    ", Product: " + productId +
    ", OS: " + osType +
    ", P2P: " + (supportsP2P == 1 ? "Yes" : "No"));
```

### Pattern 7: Service Death Recovery

```java
// Register death callback for automatic recovery
manager.registerDeathCallback(() -> {
    Log.e(TAG, "Tianqin-Lyra service died, re-initializing...");

    // Re-initialize manager
    NetworkingManager newManager = NetworkingManager.getInstance(context);

    // Re-register all listeners
    newManager.addServiceListener(filter, listener);

    // Re-publish services
    newManager.addServiceInfo(serviceInfo);
});
```

### Pattern 8: Cleanup on Activity/Service Destroy

```java
@Override
protected void onDestroy() {
    super.onDestroy();

    // Remove listeners
    manager.removeServiceListener(listener);

    // Remove published services
    manager.removeServiceInfo(serviceInfo);

    // Unregister death callback
    manager.unregisterDeathCallback(deathCallback);

    // Unbind service
    manager.unbindService();
}
```

## Best Practices

1. **Service Data Usage**: Only store capability information (version, features, flags) in service data, not volatile data like IP addresses

2. **Service Name Convention**: Keep service names under 12 bytes, use alphanumeric characters only, avoid special symbols

3. **Filter Appropriately**: Use ServiceFilter to reduce unnecessary callbacks and improve performance

4. **Handle Death Callbacks**: Always register death callbacks to handle service crashes gracefully

5. **Cleanup Resources**: Always remove listeners and services in onDestroy() to prevent memory leaks

6. **Policy Updates**: Use updateNetworkingPolicy() sparingly, only when you need accelerated discovery

7. **Thread Safety**: ServiceListener callbacks may come on different threads, use runOnUiThread() for UI updates

8. **Query vs Listen**: Use getTrustedDeviceList() for one-time queries, addServiceListener() for continuous monitoring
