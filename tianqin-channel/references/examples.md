# Tianqin Channel Code Examples

## Complete Server-Client Example

### Server Side (Receiver)

```java
public class ChannelServerActivity extends AppCompatActivity {
    private ContinuityChannelManager mChannelManager;
    private ServiceName mServiceName;
    private Channel mChannel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        mChannelManager = ContinuityChannelManager.getInstance(this);
        mServiceName = new ServiceName(getPackageName(), "fileTransfer");

        // Register death callback
        mChannelManager.registerDeathCallback(() -> {
            Log.e(TAG, "Service died, re-registering...");
            registerChannelListener();
        });

        registerChannelListener();
    }

    private void registerChannelListener() {
        ServerChannelOptions options = new ServerChannelOptions.Builder()
            .setTrustLevel(TrustLevel.SAME_ACCOUNT)
            .build();

        int result = mChannelManager.registerChannelListener(
            mServiceName, options, mChannelListener, getMainExecutor());

        if (result != 0) {
            Log.e(TAG, "Failed to register listener: " + result);
        }
    }

    private final ChannelListener mChannelListener = new ChannelListener() {
        @Override
        public void onChannelConfirm(String deviceId, ServiceName serviceName,
                int channelId, ConfirmInfo confirmInfo) {
            // Verify connecting app
            if (SameAccountConfirmUtils.isConfirmForAndroidSameApp(
                    ChannelServerActivity.this, confirmInfo)) {
                mChannelManager.confirmChannel(channelId, ConfirmStatus.ACCEPT);
            } else {
                mChannelManager.confirmChannel(channelId, ConfirmStatus.REFUSE);
            }
        }

        @Override
        public void onChannelCreateSuccess(@NonNull Channel channel) {
            mChannel = channel;
            Log.i(TAG, "Channel created: " + channel.getChannelId());
        }

        @Override
        public void onChannelCreateFailed(@NonNull ServiceName serviceName,
                int channelId, int errorCode) {
            Log.e(TAG, "Channel failed: " + errorCode);
        }

        @Override
        public void onChannelReceive(@NonNull Channel channel, @NonNull Packet packet) {
            if (packet.getPacketType() == PacketType.BYTES) {
                byte[] data = packet.asBytes();
                String message = new String(data);
                Log.i(TAG, "Received message: " + message);

                // Echo back
                channel.send(Packet.fromBytes(("Echo: " + message).getBytes()));

            } else if (packet.getPacketType() == PacketType.FILE) {
                File saveFile = new File(getFilesDir(), packet.getFilename());
                packet.asFile(saveFile);
                Log.i(TAG, "Receiving file: " + packet.getFilename());
            }
        }

        @Override
        public void onChannelTransferProgressUpdate(@NonNull Channel channel,
                @NonNull Packet packet, PacketTransferProgress progress) {
            float percent = progress.getTotalLength() > 0 ?
                (float) progress.getTransferredLength() / progress.getTotalLength() : 0;
            Log.i(TAG, "Receive progress: " + (int)(percent * 100) + "%");

            if (progress.getTransferState() == PacketTransferState.SUCCEEDED) {
                Log.i(TAG, "File received successfully");
            }
        }

        @Override
        public void onChannelRelease(@NonNull Channel channel, int code) {
            Log.i(TAG, "Channel released: " + code);
            mChannel = null;
        }
    };

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (mChannel != null) {
            mChannelManager.destroyChannel(mChannel.getChannelId());
        }
        mChannelManager.unregisterChannelListener(mServiceName);
        mChannelManager.unbindService();
    }
}
```

### Client Side (Sender)

```java
public class ChannelClientActivity extends AppCompatActivity {
    private ContinuityChannelManager mChannelManager;
    private Channel mChannel;
    private int mChannelId = -1;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        mChannelManager = ContinuityChannelManager.getInstance(this);
    }

    public void connectToDevice(String deviceId) {
        ServiceName serviceName = new ServiceName("com.target.app", "fileTransfer");

        ClientChannelOptions options = new ClientChannelOptions.Builder()
            .setConnectMediumType(ConnectMediumType.NONE)
            .setTrustLevel(TrustLevel.SAME_ACCOUNT)
            .setTimeout(15000)
            .build();

        mChannelId = mChannelManager.createChannel(
            deviceId, serviceName, options, mChannelListener, getMainExecutor());

        if (mChannelId < 0) {
            String error = ErrorCodeInfoManager.getErrMsg(this, mChannelId);
            Log.e(TAG, "Create channel failed: " + error);
        }
    }

    private final ChannelListener mChannelListener = new ChannelListener() {
        @Override
        public void onChannelConfirm(String deviceId, ServiceName serviceName,
                int channelId, ConfirmInfo confirmInfo) {
            mChannelManager.confirmChannel(channelId, ConfirmStatus.ACCEPT);
        }

        @Override
        public void onChannelCreateSuccess(@NonNull Channel channel) {
            mChannel = channel;
            Log.i(TAG, "Connected to device: " + channel.getDeviceId());
        }

        @Override
        public void onChannelCreateFailed(@NonNull ServiceName serviceName,
                int channelId, int errorCode) {
            Log.e(TAG, "Connection failed: " + errorCode);
        }

        @Override
        public void onChannelReceive(@NonNull Channel channel, @NonNull Packet packet) {
            if (packet.getPacketType() == PacketType.BYTES) {
                String response = new String(packet.asBytes());
                Log.i(TAG, "Response: " + response);
            }
        }

        @Override
        public void onChannelRelease(@NonNull Channel channel, int code) {
            mChannel = null;
        }
    };

    public void sendMessage(String message) {
        if (mChannel != null) {
            mChannel.send(Packet.fromBytes(message.getBytes()));
        }
    }

    public void sendFile(File file) {
        if (mChannel == null) return;

        Packet packet = Packet.fromFile(file, "user_file");
        mChannel.send(packet, (pkt, progress) -> {
            switch (progress.getTransferState()) {
                case PacketTransferState.SUCCEEDED:
                    Log.i(TAG, "File sent successfully");
                    break;
                case PacketTransferState.IN_PROGRESS:
                    float percent = (float) progress.getTransferredLength()
                        / progress.getTotalLength();
                    Log.i(TAG, "Sending: " + (int)(percent * 100) + "%");
                    break;
                case PacketTransferState.FAILED:
                    Log.e(TAG, "Send failed");
                    break;
                case PacketTransferState.CANCELLED:
                    Log.w(TAG, "Send cancelled");
                    break;
            }
        }, getMainExecutor());
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (mChannel != null) {
            mChannelManager.destroyChannel(mChannel.getChannelId());
        }
        mChannelManager.unbindService();
    }
}
```

## File Transfer Patterns

### Send File with Progress

```java
public void sendFileWithProgress(Channel channel, File file,
        Consumer<Float> progressCallback, Runnable onSuccess, Consumer<String> onError) {

    Packet packet = Packet.fromFile(file, file.getName());

    channel.send(packet, (pkt, progress) -> {
        switch (progress.getTransferState()) {
            case PacketTransferState.SUCCEEDED:
                onSuccess.run();
                break;
            case PacketTransferState.IN_PROGRESS:
                if (progress.getTotalLength() > 0) {
                    float percent = (float) progress.getTransferredLength()
                        / progress.getTotalLength();
                    progressCallback.accept(percent);
                }
                break;
            case PacketTransferState.FAILED:
                onError.accept("Transfer failed");
                break;
            case PacketTransferState.CANCELLED:
                onError.accept("Transfer cancelled");
                break;
        }
    }, getMainExecutor());
}
```

### Receive File with Progress

```java
@Override
public void onChannelReceive(@NonNull Channel channel, @NonNull Packet packet) {
    if (packet.getPacketType() == PacketType.FILE) {
        // Start receiving - file will be saved asynchronously
        File saveFile = new File(getExternalFilesDir(null), packet.getFilename());
        packet.asFile(saveFile);
    }
}

@Override
public void onChannelTransferProgressUpdate(@NonNull Channel channel,
        @NonNull Packet packet, PacketTransferProgress progress) {

    if (packet.getPacketType() != PacketType.FILE) return;

    switch (progress.getTransferState()) {
        case PacketTransferState.SUCCEEDED:
            // File is now ready to use
            notifyFileReceived(packet.getFilename());
            break;
        case PacketTransferState.IN_PROGRESS:
            updateProgressUI(progress.getTransferredLength(), progress.getTotalLength());
            break;
        case PacketTransferState.FAILED:
        case PacketTransferState.CANCELLED:
            notifyError("File transfer failed");
            break;
    }
}
```

### Cancel Transfer

```java
private Packet mCurrentPacket;

public void sendFile(File file) {
    mCurrentPacket = Packet.fromFile(file);
    channel.send(mCurrentPacket, progressCallback, executor);
}

public void cancelTransfer() {
    if (mCurrentPacket != null && !mCurrentPacket.isDiscarded()) {
        mCurrentPacket.discard();
    }
}
```

## Channel Confirmation Patterns

### Same Account Android App

```java
@Override
public void onChannelConfirm(String deviceId, ServiceName serviceName,
        int channelId, ConfirmInfo confirmInfo) {
    if (SameAccountConfirmUtils.isConfirmForAndroidSameApp(context, confirmInfo)) {
        channelManager.confirmChannel(channelId, ConfirmStatus.ACCEPT);
    } else {
        channelManager.confirmChannel(channelId, ConfirmStatus.REFUSE);
    }
}
```

### Cross-Platform (Android + PC)

```java
@Override
public void onChannelConfirm(String deviceId, ServiceName serviceName,
        int channelId, ConfirmInfo confirmInfo) {

    // Android same app
    if (SameAccountConfirmUtils.isConfirmForAndroidSameApp(context, confirmInfo)) {
        channelManager.confirmChannel(channelId, ConfirmStatus.ACCEPT);
        return;
    }

    // PC app with known signature
    HashMap<String, String> allowedApps = new HashMap<>();
    allowedApps.put("com.mycompany.pcapp", "abc123signature");

    if (SameAccountConfirmUtils.isConfirmForApp(confirmInfo, allowedApps)) {
        channelManager.confirmChannel(channelId, ConfirmStatus.ACCEPT);
        return;
    }

    channelManager.confirmChannel(channelId, ConfirmStatus.REFUSE);
}
```

### P2P with User Confirmation

```java
@Override
public void onChannelConfirm(String deviceId, ServiceName serviceName,
        int channelId, ConfirmInfo confirmInfo) {

    if (SameAccountConfirmUtils.isConfirmForAndroidSameApp(context, confirmInfo)) {
        if (confirmInfo.getMediumType() == MediumType.WIFI_P2P) {
            // P2P requires user confirmation
            showConfirmDialog(confirmInfo.getComparisonNumber(), () -> {
                channelManager.confirmChannel(channelId, ConfirmStatus.ACCEPT);
            }, () -> {
                channelManager.confirmChannel(channelId, ConfirmStatus.REFUSE);
            });
        } else {
            channelManager.confirmChannel(channelId, ConfirmStatus.ACCEPT);
        }
    }
}

private void showConfirmDialog(String pin, Runnable onAccept, Runnable onReject) {
    new AlertDialog.Builder(this)
        .setTitle("Connection Request")
        .setMessage("Confirm PIN: " + pin)
        .setPositiveButton("Accept", (d, w) -> onAccept.run())
        .setNegativeButton("Reject", (d, w) -> onReject.run())
        .show();
}
```

## Using V2 APIs with User Data

### Client with Custom Data

```java
ClientChannelOptionsV2 options = new ClientChannelOptionsV2.Builder()
    .setConnectMediumType(ConnectMediumType.NONE)
    .setTrustLevel(TrustLevel.SAME_ACCOUNT)
    .setTimeout(15000)
    .setUserData("{\"version\":\"1.0\",\"feature\":\"fileShare\"}")
    .build();

channelManager.createChannelV2(deviceId, serviceName, options, listener, executor);
```

### Server Confirm with Response Data

```java
@Override
public void onChannelConfirmV2(String deviceId, ServiceName serviceName,
        int channelId, ConfirmInfoV2 confirmInfo) {

    // Read client's user data
    String clientData = confirmInfo.getUserData();
    Log.i(TAG, "Client data: " + clientData);

    // Send response data back to client
    String serverResponse = "{\"accepted\":true,\"serverVersion\":\"2.0\"}";
    channelManager.confirmChannelV2(channelId, ConfirmStatus.ACCEPT, serverResponse);
}
```

## Large Data Transfer (2.0+)

```java
public void sendLargeData(Channel channel, byte[] largeData) {
    if (channel.hasFragmentSupport()) {
        // SDK will auto-fragment
        channel.send(Packet.fromBytes(largeData));
    } else {
        // Manual chunking for older versions
        int chunkSize = 65408; // 64KB - 128B
        for (int i = 0; i < largeData.length; i += chunkSize) {
            int end = Math.min(i + chunkSize, largeData.length);
            byte[] chunk = Arrays.copyOfRange(largeData, i, end);
            channel.send(Packet.fromBytes(chunk));
        }
    }
}
```

## Sync Send (Request-Response)

```java
public String sendRequest(Channel channel, String request) {
    if (!channel.hasSyncSendSupport()) {
        throw new UnsupportedOperationException("Sync send not supported");
    }

    try {
        Packet response = channel.syncSend(Packet.fromBytes(request.getBytes()));
        return new String(response.asBytes());
    } catch (SyncSendException e) {
        Log.e(TAG, "Sync send failed", e);
        return null;
    }
}
```

## Query Channel Info

```java
public void logChannelInfo(Channel channel) {
    ChannelInfo info = channel.getChannelInfo();
    if (info != null) {
        Log.i(TAG, "Channel ID: " + info.getChannelId());
        Log.i(TAG, "Device ID: " + info.getDeviceId());
        Log.i(TAG, "Address: " + info.getAddress() + ":" + info.getPort());
        Log.i(TAG, "Role: " + (info.getChannelRole() == ChannelRole.SERVER ? "Server" : "Client"));
    }

    // Get medium type
    Bundle mediumInfo = channelManager.getChannelInfoExt(
        channel.getChannelId(), ChannelInfoKeyType.CHANNEL_INFO_CONNECTION_MEDIUM_TYPE);
    int mediumType = mediumInfo.getInt(ChannelInfoKeyType.CHANNEL_KEY_MEDIUM_TYPE);
    Log.i(TAG, "Medium: " + getMediumName(mediumType));
}
```
