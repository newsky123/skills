# Tianqin Networking API Reference

## NetworkingManager Interface

接口类：`com.xiaomi.continuity.networking.NetworkingManager`
维护人：@彭建新 @杨少卿
更新日期：25/6/25

**重要提示：业务接入天琴发布前需通过兼容性测试！**

## Core Concepts

### 自组网能力

软总线组网提供的能力：
1. 可信设备在满足条件后，会自动进行组网，并同步设备基本信息（通过动态策略尽快保证实时性，但做不到真正实时lost）
2. 提供服务上下线回调通知，以及关键设备信息的变更通知

### 可信设备范围（满足其一即可）
1. 同账号的设备
2. 通过点对点绑定的非同账号设备（当前版本暂不支持，规划中）

### 自组网条件（同时满足）
1. 设备可信
2. 开启蓝牙，并在蓝牙范围内可见；或是同一局域网，且该局域网设备可通信

### 性能指标
- **设备上线时间**：一般在1-5s左右，不同条件时，时间不同
- **设备下线时间**：一般在10s-1分钟左右，不同条件时，时间不同
- 如需加速设备下线时间，可按需短时间调整组网策略，参考 `updateNetworkingPolicy` 接口

## API Methods

### 1. addServiceListener - 注册服务监听

注册服务上下线监听。该服务监听代表周边是否有匹配服务的设备上线或是下线。

**重要说明：**
- 本地设备的变更或是服务的变更不会通知，只会通知远端设备的变化情况
- 自组网监听回调实时性根据功耗和性能策略进行调节，上线和下线具备一定的时延
- 如业务需要加速，需要自定义策略

```java
int addServiceListener(ServiceFilter filter, @NonNull ServiceListener listener)
```

**参数：**
- `filter`: 指定设备过滤器，不设置时，为不过滤
- `listener`: 监听器

**返回值：**
- `int`: 注册成功结果。0成功，非0失败

---

### 2. removeServiceListener - 取消服务监听

取消设备监听。

```java
void removeServiceListener(@NonNull ServiceListener listener)
```

**参数：**
- `listener`: 监听器

---

### 3. updateNetworkingPolicy - 主动更新广播发现策略

更新广播发现策略，让设备快速上下线。调用后，会提高广播和发现的频率，以及进行设备连通性校验，以达到将缓存中的设备下线，新设备上线。

```java
int updateNetworkingPolicy(@NetworkingPolicyFlags int policy, @NonNull String tag)

// 3.0及之后版本支持
int updateNetworkingPolicy(@NetworkingPolicyFlags int policy, @NonNull String tag,
        @NonNull DeviceFilter deviceFilter)
```

**参数：**
- `policy`: 组网策略编号，参考 NetworkingPolicyFlags
- `tag`: 调用者标识非空。建议填写应用的包名，用于后续定位问题使用
- `deviceFilter`: 远端设备指定刷新的设备列表，为空则表示刷新所有远端设备

**返回值：**
- `int`: 0成功，非0失败

**NetworkingPolicyFlags 值：**

| 参数 | 值 | 描述 |
|------|-----|------|
| UPDATE_POLICY_USER_DEFAULT | 0 | 默认用户自定义策略。预计设备Lost时间为10s，新设备上线时间为5s |
| UPDATE_POLICY_ONDEMAND_NETWORKING | 1 | 按需启用自组网策略。可发现周边设备，使用停止后，如无可用连接，则设备会下线 |
| UPDATE_POLICY_RESTRICTED_WLAN_NETWORKING | 2 | 触发受限局域网刷新策略，该策略会刷新设备列表，加速新设备的上线 |
| UPDATE_POLICY_APPLE_BLE_NETWORKING | 3 | 按需启动苹果设备的ble组网，单次调用会触发组网在线时长最长269秒（仅苹果设备有效，3.0+） |
| UPDATE_POLICY_REMOTE_NETWORKING | 4 | 触发端云组网，一次调用会触发端云在线最长1分钟（3.0+） |
| UPDATE_POLICY_START_CONTINUOUS_APPLE_BLE | 5 | 触发安卓端长时间的苹果ble广播，主要用于苹果端向安卓端发起连接 |
| UPDATE_POLICY_STOP_CONTINUOUS_APPLE_BLE | 6 | 停止安卓端的长时间苹果ble广播 |

---

### 4. addServiceInfo - 添加设备服务信息

设置本机的服务信息，如果服务已存在，则会覆盖（根据服务名覆盖）。添加之后会持久化保存，即使应用被杀，添加的服务信息也将发布。

**重要说明：**
- ServiceInfo的数据只适合存放能力信息，如版本号、支持特性、以及部分由用户开关控制的一些能力信息
- 不适合放易变的数据，如IP地址等
- 数据更新后，周边设备在亮屏情况或亮屏后可通过ServiceListener感知到，时间延时预计在1s~30s不等

```java
@RequiresPermission("com.xiaomi.permission.BIND_CONTINUITY_SERVICE_INTERNAL")
int addServiceInfo(@NonNull BusinessServiceInfo serviceInfo)

// 3.0及之后版本支持
@RequiresPermission(value = "com.xiaomi.permission.BIND_CONTINUITY_SERVICE_INTERNAL")
int addServiceInfo(@NonNull BusinessServiceInfo serviceInfo, @NonNull ServiceInfoOption option)
```

**参数：**
- `serviceInfo`: 服务名和服务数据，服务数据的长度不超过32字节。packageName属性将由天琴服务设置为当前应用的packageName
- `option`: 服务信息可选参数（3.0+）

**返回值：**
- `int`: 0成功，非0失败

---

### 5. removeServiceInfo - 移除设备服务信息

删除本机的服务信息，根据服务名信息进行删除。

```java
int removeServiceInfo(@NonNull BusinessServiceInfo serviceInfo)
```

**参数：**
- `serviceInfo`: 服务名和服务数据。packageName属性将由天琴服务设置为当前应用的packageName

**返回值：**
- `int`: 0成功，非0失败

---

### 6. getLocalDeviceInfo - 查询本地设备信息

获取本地设备信息。

```java
TrustedDeviceInfo getLocalDeviceInfo()
```

**返回值：**
- `TrustedDeviceInfo`: 本地设备信息，其中只有设备ID、设备类型和设备名称是有效的，其他都无效

---

### 7. getTrustedDeviceInfo - 根据设备ID获取设备信息

根据设备ID查询设备信息。

```java
TrustedDeviceInfo getTrustedDeviceInfo(@NonNull String devId)
```

**参数：**
- `devId`: 设备Id

**返回值：**
- `TrustedDeviceInfo`: 设备信息，如果设备不在线返回null

---

### 8. getTrustedDeviceList - 获取设备列表

查询设备列表。如需获取设备中是否有想要的服务，则需要遍历过滤。

```java
List<TrustedDeviceInfo> getTrustedDeviceList()

// 3.0及之后版本支持
List<TrustedDeviceInfo> getTrustedDeviceList(ServiceFilter filter)

// 3.0及之后版本支持（异步调用）
AsyncResult<List<TrustedDeviceInfo>> getTrustedDeviceList(ServiceFilter filter,
        TrustedDeviceFilter deviceFilter)
```

**参数：**
- `filter`: 设备过滤器，不设置时，为不过滤
- `deviceFilter`: 设备过滤器，不设置时，为不过滤

**返回值：**
- `List<TrustedDeviceInfo>`: 设备信息列表，只返回在线的设备列表

---

### 9. getServiceInfo - 获取设备服务信息

获取设备的服务信息。

```java
BusinessServiceInfo getServiceInfo(@NonNull String devId, @NonNull ServiceName serviceName)
```

**参数：**
- `devId`: 设备Id
- `serviceName`: 服务名

**返回值：**
- `BusinessServiceInfo`: 服务信息和数据，未有匹配信息返回null

---

### 10. getServiceInfoList - 获取设备的所有服务列表信息

获取设备的所有服务列表信息。

```java
List<BusinessServiceInfo> getServiceInfoList(@NonNull String devId)
```

**参数：**
- `devId`: 设备Id

**返回值：**
- `List<BusinessServiceInfo>`: 服务信息列表，未有匹配信息返回null

---

### 11. getIntProperty/getStringProperty - 获取远端设备信息

获取设备的属性信息。

```java
int getIntProperty(@NonNull String devId, int prop)
String getStringProperty(@NonNull String devId, int prop)
```

**参数：**
- `devId`: 设备Id
- `prop`: 属性类型，参考PropertyType的定义

**返回值：**
- `int/String`: 对应的属性值

**PropertyType 类型：**

| 参数 | 值 | 返回类型 | 描述 | 备注 |
|------|-----|----------|------|------|
| PropIpAddr | 0 | String | IP地址 | 如果设备id是本端的，返回127.0.0.1；如果设备局域网下线了为空 |
| PropBtAddr | 1 | String | 蓝牙地址 | 需要蓝牙权限。受平台差异影响，非蓝牙组网情况下，存在获取不到蓝牙地址的情况 |
| PropP2PAddr | 2 | String | P2P地址 | 需要IP权限。建议通过创建通道之后从通道属性中获取 |
| PropSupportP2P | 3 | int | 是否支持p2p | 1支持，0不支持 |
| PropSupportRfcomm | 4 | int | 是否支持蓝牙Rfcomm | 1支持，0不支持 |
| PropSupportNogroup | 5 | int | 是否支持点对点组网 | 1支持，0不支持 |
| PropOSType | 6 | int | OS类型 | Android 1, Linux 2, Windows 3, Vela 4 |
| PropProductID | 7 | String | 产品ID | Android: android.os.Build.MODEL |
| PropLyraVersion | 8 | String | 天琴版本 | 天琴runtime的版本号 |
| PropScreenState | 9 | int | 屏幕状态 | 不建议上层业务通过此属性获取屏幕状态 |
| PropSupportLinkData | 10 | int | 一对多是否支持大数据 | 1支持，0不支持 |
| PropBuildRegion | 11 | String | 区域 | 如cn |
| PropUserId | 12 | String | 用户账户ID Hash | |
| PropMarketName | 13 | String | 产品名称 | 如RedMi Note 10 Pro, Mi 10 Ultra |
| PropIsBindDevice | 14 | int | 查看该设备是否与当前设备绑定 | |
| PropModelName | 15 | String | 产品型号 | 如zeus, elish |
| PropSupportBleAdvMerge | 16 | int | 是否支持普通广播和命令广播合并 | 3.0+ |
| PropWifiSwitch | 17 | int | wifi开关状态 | 1：开 2：关 0：未知（3.0+） |
| PropWifiConnectStatus | 18 | int | wifi连接状态 | 1：已连接 2：未连接 0：未知（3.0+） |
| PropBleSwitch | 19 | int | ble开关状态 | 1：开 2：关 3：半开 0：未知（3.0+） |
| PropLyraSwitch | 20 | int | 互联互通开关状态 | 1：开 2：关 0：未知（3.0+） |
| PropDeviceName | 21 | String | 设备名称 | 3.0+ |
| PropUniDid | 22 | String | 唯一设备标识 | 3.0+ |
| PropMarketAndModelName | 23 | String | 产品名称.产品型号 | 属性不再使用（3.0+） |
| PropFeaturesId | 24 | int | 天琴能力信息 | 属性不再使用（3.0+） |
| PropUid | 25 | int | 获取天琴进程uid | 3.0+ |
| PropIsTopologyDirectLink | 26 | int | 查看该设备是否和当前设备在拓扑上直连 | 3.0+ |
| PropSupportBleApple | 27 | int | 是否支持苹果ble组网 | 3.0+ |
| PropSupportRemote | 28 | int | 是否支持端云组网 | 3.0+ |
| PropOSVersion | 29 | String | 设备OS版本 | 3.0+ |

---

### 12. registerDeathCallback - 注册服务端死亡通知

注册服务端死亡通知。该场景表示天琴服务端异常退出了。

该能力对标Android的Service的死亡通知，与android的linkToDeath功能类似，用于处理天琴异常退出后的一些容错处理，如需要重新绑定天琴服务，并重新注册ServiceListener。

```java
void registerDeathCallback(@NonNull Runnable deathCallback)
```

**参数：**
- `deathCallback`: 死亡通知。服务端死亡之后，需要重新注册以及设置。deathCallback在sdk中会缓存，不需要多次调用registerDeathCallback

---

### 13. unregisterDeathCallback - 取消注册服务端死亡通知

取消注册服务端死亡通知。

```java
void unregisterDeathCallback(@NonNull Runnable deathCallback)
```

**参数：**
- `deathCallback`: 死亡通知

---

### 14. getInstance - 获取组网实例

单例方式获取组网管理实例。

```java
static synchronized NetworkingManager getInstance(@NonNull Context context)
```

**参数：**
- `context`: Android context上下文对象

**返回值：**
- `NetworkingManager`: 组网管理类

---

### 15. unbindService - 解绑服务

与天琴组网服务NetworkingService解绑。

**解绑前需请执行清理工作：**
1. 注销所有callback、listener
2. 执行对应的stop、remove操作

组网功能注销接口：removeServiceListener、removeServiceInfo、unregisterDeathCallback

```java
public void unbindService()
```

---

### 16. setNetworkingType - 设置组网类型

设置组网类型。

**注意：该接口目前仅为车机MIS使用，其他业务请勿使用。**

```java
public int setNetworkingType(int networkingTypes)
```

**参数：**
- `networkingTypes`: 组网类型，参见NetworkingType定义

**返回值：**
- `int`: 结果描述可通过ErrorCodeInfoManager.getErrMsg(Context, int)获取

## Callbacks

### ServiceListener - 服务监听器

服务监听器用于监听设备和服务的上下线、变更事件。

```java
public interface ServiceListener {
    // 下线原因常量
    int OFFLINE_OTHER = 0;          // 未知原因
    int OFFLINE_DEVICE_LOST = 1;    // 设备不在周边，如关机、远离等场景
    int OFFLINE_UNTRUSTED = 2;      // 设备可信关系变化，如退出账号、解绑等原因
    int SERVICE_REMOVED = 3;        // 服务被移除

    /**
     * 服务上线
     * @param serviceInfo 服务信息
     * @param deviceInfo 设备信息
     */
    void onServiceOnline(BusinessServiceInfo serviceInfo, TrustedDeviceInfo deviceInfo);

    /**
     * 服务下线
     * @param serviceInfo 服务信息
     * @param deviceInfo 设备信息
     * @param reason 下线原因
     */
    void onServiceOffline(BusinessServiceInfo serviceInfo, TrustedDeviceInfo deviceInfo, int reason);

    /**
     * 设备变更
     * 变更的场景包括，但不限于：信任关系（同账号、点对点关系的新增和删除）、设备名称、组网媒介
     * @param deviceInfo 设备信息
     */
    void onDeviceChanged(TrustedDeviceInfo deviceInfo);

    /**
     * 服务变更
     * @param serviceInfo 服务信息
     * @param deviceInfo 设备信息
     */
    void onServiceChanged(BusinessServiceInfo serviceInfo, TrustedDeviceInfo deviceInfo);
}
```

**重要说明：**
- 由于 `onChannelCreateSuccess` 和 `onServiceOnline` 这两个回调之间没有明确的先后顺序，当设备被连接时，可能存在未组网上线的情况，此时上层业务可通过查询的方式获取设备信息

## Data Types

### TrustedDeviceInfo - 设备信息

```java
public class TrustedDeviceInfo implements Parcelable {
    private String mDeviceId;           // 设备ID
    private int mDeviceType;            // 设备类型
    private String mDeviceName;         // 设备名称
    private int mMediumTypes;           // 设备组网类型
    private int mTrustedTypes;          // 设备信任关系类型

    // 方法
    public String getDeviceId()         // 获取设备ID，设备唯一标识
    public int getDeviceType()          // 获取设备类型
    public String getDeviceName()       // 获取设备名称
    public int getMediumTypes()         // 获取设备组网类型
    public int getTrustedTypes()        // 获取设备的可信关系
    public boolean hasBle()             // 是否为BLE组网
    public boolean hasWlan()            // 是否为WLAN组网
    public boolean hasTrustedType(int trustedType)  // 是否存在指定类型的trustedType
    public boolean hasMediumType(int mediumType)    // 是否存在指定类型的mediumType
}
```

**DeviceTypeFlags 类型：**

| 定义 | 值 | 描述 |
|------|-----|------|
| DEVICE_TYPE_NONE | 0 | 未知 |
| DEVICE_TYPE_PHONE | 1 | 手机 |
| DEVICE_TYPE_PAD | 2 | PAD |
| DEVICE_TYPE_TV | 3 | 电视 |
| DEVICE_TYPE_PC | 4 | 电脑 |
| DEVICE_TYPE_SOUND | 5 | 有屏音箱 |
| DEVICE_TYPE_VELA_WEAR | 6 | Vela手表 |
| DEVICE_TYPE_VELA_SOUND | 7 | Vela音箱 |
| DEVICE_TYPE_MI_AUTOMOTIVE | 8 | 车机 |
| DEVICE_TYPE_ROUTER | 9 | 路由器 |
| DEVICE_TYPE_CAMERA | 10 | 相机 |
| DEVICE_TYPE_IPHONE | 11 | 苹果手机 |
| DEVICE_TYPE_IPAD | 12 | 苹果平板 |
| DEVICE_TYPE_IMAC | 13 | 苹果iMac设备 |
| DEVICE_TYPE_MACBOOK | 14 | 苹果Macbook设备 |
| DEVICE_TYPE_MAC_STUDIO | 15 | 苹果Mac Studio设备 |
| DEVICE_TYPE_MAC_MINI | 16 | 苹果Mac mini设备 |
| DEVICE_TYPE_MAC_PRO | 17 | 苹果Mac Pro设备 |
| DEVICE_TYPE_GLASSES | 18 | 眼镜 |
| DEVICE_TYPE_WATCH | 19 | 手表 |
| DEVICE_TYPE_OTHER_PC | 21 | 非小米PC |
| DEVICE_TYPE_MIWEAR_BLE_BAND | 16777217 | 手表 |
| DEVICE_TYPE_MIWEAR_BLE_WATCH | 16777218 | 手环 |
| DEVICE_TYPE_MIWEAR_DUAL_BAND | 16777219 | 双模的手环 |
| DEVICE_TYPE_MIWEAR_DUAL_WATCH | 16777220 | 双模的手表 |

**MediumTypeFlags 类型：**

| 定义 | 值 | 描述 |
|------|-----|------|
| MEDIUM_TYPES_BLE | 2 | BLE组网 |
| MEDIUM_TYPES_WLAN | 128 | 局域网组网，包括通过WLAN、ETH等各种局域网方式 |

**TrustedTypeFlags 类型：**

| 定义 | 值 | 描述 |
|------|-----|------|
| TRUSTED_TYPES_SAME_ACCOUNT | 1 | 同账号关系 |
| TRUSTED_TYPES_P2P_GROUP | 2 | 点对点绑定组网关系 |

---

### BusinessServiceInfo - 服务信息

```java
public class BusinessServiceInfo implements Parcelable {
    private String serviceName;     // 服务名，需全局唯一
    private String packageName;     // 应用名，不同应用名不一样
    private byte[] serviceData;     // 服务数据

    // 方法
    public String getServiceName()
    public byte[] getServiceData()
    public String getPackageName()
    public void setServiceName(String name)
    public void setServiceData(byte[] data)
    public void setPackageName(String packageName)
}
```

**重要说明：**
- 服务数据长度不超过32字节
- 服务名建议不超过12字节，有字母和数字组成，不包含特殊符号，如 ,/.#: 等
- 服务数据建议按bit位使用。当服务数据发生变化时，会触发组网间设备的同步，对系统开销比较大
- 该数据不能是易变的内容。该数据变更后，远端设备能收到变更通知

---

### ServiceFilter - 设备过滤器（3.0+）

设置条件时，则所有条件满足方可表示满足条件。

```java
public class ServiceFilter {
    private List<Integer> deviceTypeFilter;     // 按设备类型过滤
    private ServiceName serviceFilter;          // 指定服务过滤
    private List<Integer> trustedTypeFilter;    // 按设备的信任关系过滤
    private List<Integer> mediumTypeFilter;     // 按媒介类型过滤
}
```

---

### TrustedDeviceFilter - 设备过滤器

用于订阅设备上下线，以及查询设备列表时，过滤设备场景使用。

```java
public class TrustedDeviceFilter {
    /**
     * 指定设备类型过滤
     * @param typeFilter 过滤指定类型的设备，不指定时，不进行过滤
     */
    public void setDeviceType(List<Integer> typeFilter);

    /**
     * 指定服务信息
     * @param serviceFilter 服务Name。不设置时，不过滤。只能设置一个
     */
    public void setServiceFitler(ServiceFilter serviceFilter);

    /**
     * 指定是否同步获取云端数据（3.0+）
     * @param syncCloud 是否同步获取云端数据
     */
    public void setSyncCloud(boolean syncCloud);

    /**
     * 指定是否包含offline的设备信息（3.0+）
     * @param containsOffline 是否包含offline的设备信息
     */
    public void setContainsOffline(boolean containsOffline);

    public String toFilterString();
}
```

---

### NetworkingType - 组网类型

用于控制组网类型。

```java
typedef enum NetworkingType {
    kNetworkingTypeNone = 0,
    kNetworkingTypeBle = kMediumBle,
    kNetworkingTypeWlan = kMediumWifiLan,
    kNetworkingTypeAll = kNetworkingTypeBle | kNetworkingTypeWlan,
} NetworkingType;
```

---

### ServiceInfoOption - 服务信息可选参数（3.0+）

```java
public class ServiceInfoOption implements Parcelable {
    private boolean syncCloud = false;  // 云同步，默认false

    public boolean isSyncCloud()
    public void setSyncCloud(boolean syncCloud)
}
```

---

### DeviceFilter - 设备过滤（3.0+）

```java
public class DeviceFilter implements Parcelable {
    private List<String> mDeviceIdList;  // 指定刷新设备，为空则表示刷新所有远端设备

    public List<String> getDeviceIdList()
    public void setDeviceIdList(List<String> deviceIdList)
}
```
