# Tianqin Channel API Reference

接口类：`com.xiaomi.continuity.channel.ContinuityChannelManager`

## Channel Listener Registration

### registerChannelListener - 注册传输通道回调监听

**Important:** Must register BEFORE the remote device calls `createChannel`, otherwise channel creation will fail.

```java
public int registerChannelListener(@NonNull ServiceName serviceName,
                                   @NonNull ServerChannelOptions options,
                                   @NonNull ChannelListener listener,
                                   @NonNull Executor executor)

// V2 version (3.0+)
public int registerChannelListener(@NonNull ServiceName serviceName,
                                   @NonNull ServerChannelOptionsV2 options,
                                   @NonNull ChannelListener listener,
                                   @NonNull Executor executor)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| serviceName | ServiceName | Custom service name for connection |
| options | ServerChannelOptions / ServerChannelOptionsV2 | Configuration options |
| listener | ChannelListener | Callback listener |
| executor | Executor | Callback thread pool (recommend `Context.getMainExecutor()`) |

**Returns:** `0` on success

### unregisterChannelListener - 注销通道监听回调

```java
public int unregisterChannelListener(@NonNull ServiceName serviceName)
```

## Channel Creation

### createChannel - 基于设备ID创建传输通道

```java
@Deprecated
public int createChannel(@NonNull String deviceId,
                         @NonNull ServiceName serviceName,
                         @NonNull ClientChannelOptions channelOptions,
                         @NonNull ChannelListener listener,
                         @NonNull Executor executor)

// V2 version (3.0+)
public int createChannelV2(@NonNull String deviceId,
                           @NonNull ServiceName serviceName,
                           @NonNull ClientChannelOptionsV2 channelOptions,
                           @NonNull ChannelListener listener,
                           @NonNull Executor executor)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| deviceId | String | Device ID from networking or discovery |
| serviceName | ServiceName | Must match server's registered serviceName |
| channelOptions | ClientChannelOptions / ClientChannelOptionsV2 | Channel configuration |
| listener | ChannelListener | Callback listener |
| executor | Executor | Callback thread pool |

**Returns:**
- `>=0`: Channel ID (wait for success/failure callback)
- `<0`: Error code (use `ErrorCodeInfoManager.getErrMsg(Context, int)`)

**Tips:**
- When `ConnectMediumType.NONE`, system auto-selects based on discovery medium and efficiency
- Match connection medium with discovery medium (BLE discovered → BLE connect)
- P2P does not support multi-device connections

### createChannel - 基于设备地址创建传输通道

```java
public int createChannel(@NonNull LinkAddress linkAddress,
                         @NonNull ServiceName serviceName,
                         @NonNull ClientChannelOptions channelOptions,
                         @NonNull ChannelListener listener,
                         @NonNull Executor executor)

// V2 version
public int createChannelV2(@NonNull LinkAddress linkAddress,
                           @NonNull ServiceName serviceName,
                           @NonNull ClientChannelOptionsV2 channelOptions,
                           @NonNull ChannelListener listener,
                           @NonNull Executor executor)
```

## Channel Management

### confirmChannel - 传输通道确认

Both sender and receiver must confirm. Either side refusing causes channel creation failure.

```java
@Deprecated
int confirmChannel(int channelId, int accept);

// V2 version - with user data
int confirmChannelV2(int channelId, int accept, @Nullable String userData);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| channelId | int | Channel ID from `onChannelConfirm` |
| accept | int | `ConfirmStatus.ACCEPT` (0) to accept, non-zero to refuse (custom reason) |
| userData | String | Custom data passed to client (V2 only) |

### destroyChannel - 传输通道销毁

```java
int destroyChannel(int channelId);
```

### getChannelInfoExt - 查询通道扩展属性

```java
Bundle getChannelInfoExt(int channelId, int key)
```

| Key (ChannelInfoKeyType) | Description | Bundle Keys |
|--------------------------|-------------|-------------|
| `CHANNEL_INFO_CONNECTION_MEDIUM_TYPE` | Connection medium | `CHANNEL_KEY_MEDIUM_TYPE` |
| `CHANNEL_INFO_P2P_CONFIG` | P2P configuration | `CHANNEL_KEY_P2PINFO` (JSON) |
| `CHANNEL_INFO_FREQUENCY_CHANNEL` | Frequency info | `CHANNEL_KEY_FREQUENCY` |

## ChannelListener Callbacks

```java
public interface ChannelListener {
    void onChannelConfirm(String deviceId, ServiceName serviceName,
                          int channelId, ConfirmInfo confirmInfo);
    void onChannelCreateSuccess(@NonNull Channel channel);
    void onChannelCreateFailed(@NonNull ServiceName serviceName, int channelId, int errorCode);
    void onChannelReceive(@NonNull Channel channel, @NonNull Packet packet);
    default void onChannelTransferProgressUpdate(@NonNull Channel channel,
                                                  @NonNull Packet packet,
                                                  PacketTransferProgress progress);
    void onChannelRelease(@NonNull Channel channel, int code);
}
```

### onChannelConfirm - 通道创建确认

**Critical:** Always verify `ConfirmInfo` before accepting. Never accept without validation.

```java
void onChannelConfirm(String deviceId, ServiceName serviceName,
                      int channelId, ConfirmInfo confirmInfo);

// V2 version
void onChannelConfirmV2(String deviceId, ServiceName serviceName,
                        int channelId, ConfirmInfoV2 confirmInfo);
```

**Recommended Verification Patterns:**

```java
// Pattern 1: Same account, same Android app
if (SameAccountConfirmUtils.isConfirmForAndroidSameApp(context, confirmInfo)) {
    channelManager.confirmChannel(channelId, ConfirmStatus.ACCEPT);
    return;
}

// Pattern 2: Cross-platform (PC)
HashMap<String, String> allowedApps = new HashMap<>();
allowedApps.put("com.example.pcapp", "signature");
if (SameAccountConfirmUtils.isConfirmForApp(confirmInfo, allowedApps)) {
    channelManager.confirmChannel(channelId, ConfirmStatus.ACCEPT);
    return;
}

// Pattern 3: P2P requires user confirmation
if (confirmInfo.getMediumType() == MediumType.WIFI_P2P) {
    // Show confirmation dialog with confirmInfo.getComparisonNumber()
}
```

### onChannelCreateSuccess - 通道创建成功

```java
void onChannelCreateSuccess(@NonNull Channel channel);
```

### onChannelCreateFailed - 通道创建失败

```java
void onChannelCreateFailed(@Nullable String deviceId, @NonNull ServiceName serviceName,
                           int channelId, int errorCode);
```

### onChannelReceive - 通道接收数据回调

```java
void onChannelReceive(@NonNull Channel channel, @NonNull Packet packet);
```

### onChannelTransferProgressUpdate - 通道进度更新回调

```java
default void onChannelTransferProgressUpdate(@NonNull Channel channel,
                                              @NonNull Packet packet,
                                              PacketTransferProgress progress);
```

### onChannelRelease - 通道关闭后回调

```java
void onChannelRelease(@NonNull Channel channel, int code);
```

## Data Transfer

### Channel.send - 数据发送

Default timeout (no response time, not total transfer time):
- WLAN/P2P: 30s
- BLE/Bluetooth: 10s

```java
// Without progress callback
void send(@NonNull Packet packet);

// With progress callback
void send(@NonNull Packet packet,
          @NonNull PacketTransferProgressCallback callback,
          @NonNull Executor executor);
```

### Large Data Support (2.0+)

Default max: 64KB-128B. For larger data, check support first:

```java
if (channel.hasFragmentSupport()) {
    // Can send large data - SDK auto-fragments
}
```

Requirements:
- IP channels: Both SDK 2.0+
- BLE channels: Both SDK and Runtime 2.0+

### Sync Send

```java
Packet syncSend(@NonNull Packet packet) throws SyncSendException;
boolean hasSyncSendSupport();
```

## Packet Interface

```java
public interface Packet {
    @PacketType int getPacketType();
    long getContentLength();
    String getFilename();
    String getTag();
    boolean isReceived();
    boolean isDiscarded();
    void putExtras(Bundle extras);

    // Extract data
    byte[] asBytes();
    InputStream asInputStream();
    void asFile(File file);
    void asFile(Uri fileUri);
    void asFile(FileDescriptor fd);
    void asOutput(OutputStream os);
    void discard();

    // Create packets
    static Packet fromBytes(byte[] bytes);
    static Packet fromFile(File file);
    static Packet fromFile(File file, String tag);
    static Packet fromFileStream(FileInputStream fs);
    static Packet fromUri(Uri fileUri);
}
```

| PacketType | Description |
|------------|-------------|
| `UNKNOWN` | Unknown |
| `BYTES` | Byte array |
| `FILE` | File |
| `MESSAGE` | Text message |

## Service Management

### registerDeathCallback - 注册死亡监听

```java
void registerDeathCallback(@NonNull Runnable deathCallback)
```

### unregisterDeathCallback - 取消注册死亡监听

```java
void unregisterDeathCallback(@NonNull Runnable deathCallback)
```

### unbindService - 解绑服务

Before unbinding, cleanup:
1. Unregister all callbacks/listeners
2. Execute stop/remove operations

```java
public void unbindService()
```

## Data Types

### ServiceName

```java
public class ServiceName implements Parcelable {
    private String packageName;  // App package name
    private String name;         // Service name
}
```

### ConfirmInfo

```java
public class ConfirmInfo implements Parcelable {
    @TrustLevel private int mTrustLevel;
    @NonNull private String mComparisonNumber;  // PIN for verification
    @NonNull private String mAppPackage;
    @NonNull private String mAppSignature;
    @PlatformType private int mDevicePlatformType;
    @MediumType.ConnectionMediumTypes private int mMediumType;
}
```

### ConfirmInfoV2 (3.0+)

```java
public class ConfirmInfoV2 extends ConfirmInfo {
    @Nullable private String mUserData;
    @Nullable private byte[] mSystemData;
    @Nullable private SystemDataRtm mSysDataRtm;
    @DeviceTypeV2.DeviceTypes private int mDeviceType;
}
```

### Channel

```java
public interface Channel {
    @Nullable ChannelInfo getChannelInfo();
    void send(@NonNull Packet packet);
    void send(@NonNull Packet packet, @NonNull PacketTransferProgressCallback callback,
              @NonNull Executor executor);
    @NonNull String getDeviceId();
    @NonNull ServiceName getServiceName();
    int getChannelId();
    @ChannelRole int getChannelRole();
    boolean hasFragmentSupport();
    default boolean hasSyncSendSupport();
    default int setBypassChannel(int bpChannelId);  // 3.0+
    default Key getChannelKey();  // 3.0+
}
```

### ChannelInfo

```java
public class ChannelInfo implements Parcelable {
    private final int channelId;
    private final int peerChannelId;
    @NonNull private final String deviceId;
    @NonNull private final ServiceName serviceName;
    @Nullable private final String address;
    private final int port;
    @ChannelRole private final int channelRole;
    private boolean isSdkSocket;
    @Nullable private String localAddress;
    private final byte[] transKey;
    @DeviceTypeV2.DeviceTypes private int deviceType;  // 3.0+
}
```

### ClientChannelOptions

```java
public class ClientChannelOptions implements Parcelable {
    @ConnectMediumType private int connectMediumType;
    @TrustLevel private int trustLevel;
    private int timeout;  // ms, default 10s
    @ProtocolType private int protocolType;
}
```

### ClientChannelOptionsV2

```java
public class ClientChannelOptionsV2 implements Parcelable {
    @ConnectMediumType private int connectMediumType;
    private int mExFlag;
    @TrustLevel private int trustLevel;
    private int timeout;
    @Nullable private String userData;
    @Nullable private String packageName;  // 3.0+
    private Bundle optionalValues;
}
```

### ServerChannelOptions

```java
public class ServerChannelOptions implements Parcelable {
    @TrustLevel private final int mTrustLevel;
}
```

### PacketTransferProgress

```java
public class PacketTransferProgress {
    @PacketTransferState private int transferState;
    private long totalLength;
    private long transferredLength;
}
```

### Enums

**ChannelRole:**
| Value | Description |
|-------|-------------|
| `UNKNOWN` | Unknown |
| `SERVER` | Server (receiver) |
| `CLIENT` | Client (sender) |

**TrustLevel:**
| Value | Description |
|-------|-------------|
| `SAME_ACCOUNT` (0x10) | Same Xiaomi account |
| `TRUST_GROUP` (0x20) | Trusted group (same account or bound) |
| `EVERY_ONE` (0x30) | Everyone |

**ConnectMediumType:**
| Value | Description |
|-------|-------------|
| `NONE` (0) | Auto-select |
| `BLUETOOTH` (0x01) | BT RFCOMM |
| `BLE` (0x02) | BLE |
| `P2P` (0x20) | WiFi P2P |
| `WLAN` (0x80) | WiFi LAN |
| `REMOTE` (0x40000) | Cloud relay (3.0+) |

**PacketTransferState:**
| Value | Description |
|-------|-------------|
| `SUCCEEDED` | Transfer complete |
| `IN_PROGRESS` | Transferring |
| `CANCELLED` | Cancelled |
| `FAILED` | Failed |

**PlatformType:**
| Value | Description |
|-------|-------------|
| `UNKNOWN` | Unknown |
| `ANDROID` | Android |
| `WINDOWS` | Windows |
| `LINUX` | Linux |

### LinkAddress Types

```java
// IP Address
public class IpLinkAddress extends LinkAddress {
    private Ip mIp;  // contains ip string and port
}

// Bluetooth Address
public class BtLinkAddress extends LinkAddress {
    private Bt mBt;  // contains mac address
}

// P2P Address
public class P2pLinkAddress extends LinkAddress {
    private P2p mP2p;  // contains mac, ssid, pwd, channel, ip, port
}
```

### ChannelOptionalType (3.0+)

| Key | Type | Description |
|-----|------|-------------|
| `CHANNEL_OPTIONAL_NETWORK_CARD` | int | Specify network card for LAN/P2P |
| `CHANNEL_OPTIONAL_TRANS_MODE` | int | Transfer mode (throughput priority) |
| `CHANNEL_OPTIONAL_TRUST_MODE` | int | Authentication mode |
| `CHANNEL_OPTIONAL_P2P_NOA_MODE` | int | P2P NOA mode |
| `CHANNEL_OPTIONAL_P2P_ROLE` | int | P2P negotiated role |
| `CHANNEL_OPTIONAL_PREFER_SHARED_MEMORY` | int | Prefer shared memory |
| `CHANNEL_OPTIONAL_USE_CELLULAR` | int | Allow mobile data |
| `CHANNEL_OPTIONAL_EXCLUSIVE_CONNECTION` | int | Exclusive connection |
