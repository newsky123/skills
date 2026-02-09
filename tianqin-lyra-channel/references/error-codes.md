# Tianqin-Lyra Error Codes Reference

Complete error code reference for the Tianqin-Lyra SDK. Error codes are returned in callbacks such as `onChannelCreateFailed`, `onChannelRelease`, and other failure handlers.

## Error Code Ranges

| Range | Module | Description |
|-------|--------|-------------|
| 10001-10009 | API | API layer errors |
| 11001-11008 | COM | Communication layer errors |
| 12001-12019 | ADV | Advertising errors |
| 13001-13021 | DISC | Discovery errors |
| 14001-14033 | CONN | Connection errors |
| 15001-15071 | Logical CONN | Logical connection errors |
| 16001-16053 | Physical CONN | Physical connection errors |
| 17001-17032 | Link Manager | Link management errors |
| 18001-18013 | Trans Manager | Transport manager errors |
| 19001-19015 | Trans | Transport errors |
| 20001-20012 | Invite | Invitation errors |
| 21001-21010 | Device | Device errors |
| 22001-22140 | BLE | Bluetooth Low Energy errors |
| 23001-23088 | BT | Classic Bluetooth errors |
| 24001-24015 | MISS | MISS protocol errors |
| 25001-25005 | mDNS | mDNS errors |
| 26001-26021 | WiFi | WiFi errors |
| 27001-27010 | Storage | Storage errors |
| 28001-28006 | System | System errors |
| 29001-29091 | Auth | Authentication errors |
| 30001-30002 | Crypto | Cryptography errors |
| 31001-31010 | Permission | Permission errors |
| 32001-32011 | Account | Account errors |
| 33001-33020 | KCP | KCP transport errors |
| 34001-34007 | NFC | NFC errors |
| 35001-35005 | Event | Event system errors |
| 36001-36022 | P2P Nego | P2P negotiation errors |
| 37001-37060 | QoS | Quality of Service errors |
| 51001-51003 | JNI | JNI errors |
| 52001-52022 | Channel | Channel errors |
| 53001-53024 | Networking | Networking worker errors |
| 54001-54025 | Message Center | Message center errors |
| 81001-89007 | MiWear | MiWear module errors |

---

## API Errors (10001-10009)

| Code | Description |
|------|-------------|
| 10001 | api failed |
| 10002 | api invalid param |
| 10003 | api invalid operate |
| 10004 | api not init |
| 10005 | api no memory |
| 10006 | api out of memory |
| 10007 | api no permission |
| 10008 | api not support operate |
| 10009 | api repeat service id |

## COM Errors (11001-11008)

| Code | Description |
|------|-------------|
| 11001 | com failed |
| 11002 | com invalid param |
| 11003 | com invalid operate |
| 11004 | com not init |
| 11005 | com no memory |
| 11006 | com out of memory |
| 11007 | com not support |
| 11008 | com not start |

## Advertising Errors (12001-12019)

| Code | Description |
|------|-------------|
| 12001 | adv failed |
| 12002 | adv invalid param |
| 12003 | adv invalid data |
| 12004 | adv invalid operate |
| 12005 | adv not init |
| 12006 | adv timeout |
| 12007 | adv exception |
| 12008 | adv no account |
| 12009 | adv no memory |
| 12010 | adv out of memory |
| 12011 | adv no permission |
| 12012 | adv unauthorized |
| 12013 | adv not support |
| 12014 | adv service not working |
| 12015 | adv not support data type |
| 12016 | adv not allow by env |
| 12017 | adv not stop by env |
| 12018 | adv invalid device id |
| 12019 | adv not support ble high frequency |

## Discovery Errors (13001-13021)

| Code | Description |
|------|-------------|
| 13001 | disc failed |
| 13002 | disc invalid param |
| 13003 | disc invalid data |
| 13004 | disc invalid operate |
| 13005 | disc not init |
| 13006 | disc timeout |
| 13007 | disc exception |
| 13008 | disc no account |
| 13009 | disc no memory |
| 13010 | disc out of memory |
| 13011 | disc no permission |
| 13012 | disc unauthorized |
| 13013 | disc not support |
| 13014 | disc already has listener |
| 13015 | disc has no listener |
| 13016 | disc service not working |
| 13017 | disc not support data type |
| 13018 | disc not allow by env |
| 13019 | disc load policy failed |
| 13020 | disc not stop by env |
| 13021 | disc invalid device id |

## Connection Errors (14001-14033)

| Code | Description |
|------|-------------|
| 14001 | conn failed |
| 14002 | conn invalid param |
| 14003 | conn invalid data |
| 14004 | conn invalid operate |
| 14005 | conn unsupported medium |
| 14006 | conn invalid handle |
| 14007 | conn service name conflict |
| 14008 | conn connection id conflict |
| 14009 | conn logical conn id conflict |
| 14010 | conn connection remote reject |
| 14011 | conn connection timeout |
| 14012 | conn create link server failed |
| 14013 | conn create trans server failed |
| 14014 | conn connect link server failed |
| 14015 | conn connect trans server failed |
| 14016 | conn data link exception |
| 14017 | conn trans channel exception |
| 14018 | conn keep alive timeout |
| 14019 | conn disconnection request |
| 14020 | conn peer device exception |
| 14021 | conn service not connected |
| 14022 | conn network is disabled |
| 14023 | conn p2p not support with 3rd device |
| 14024 | conn account is changed |
| 14025 | conn medium server not start |
| 14026 | conn invalid address |
| 14027 | conn not support |
| 14028 | conn get device addr failed |
| 14029 | conn no memory |
| 14030 | conn not init |
| 14031 | conn max payload |
| 14032 | conn userspace background |
| 14033 | conn ext not connected |

## Logical Connection Errors (15001-15071)

| Code | Description |
|------|-------------|
| 15001 | logical conn failed |
| 15002 | logical conn invalid param |
| 15003 | logical conn invalid data |
| 15004 | logical conn invalid operate |
| 15005 | logical conn not init |
| 15006 | logical conn timeout |
| 15007 | logical conn exception |
| 15008 | logical conn no account |
| 15009 | logical conn no memory |
| 15010 | logical conn out of memory |
| 15011 | logical conn no device link addr |
| 15012 | logical conn no inner id |
| 15013 | logical conn invalid logi id |
| 15014 | logical conn invalid protocol |
| 15015 | logical conn connection remote reject |
| 15016 | logical conn connection local reject |
| 15017 | logical conn connection manual cancel |
| 15018 | logical conn medium type error |
| 15019 | logical conn trust level error |
| 15020 | logical conn auth handshake error |
| 15021 | logical conn service name not registered |
| 15022 | logical conn connection remote disconnect |
| 15023 | logical conn send data error |
| 15024 | logical conn connection manual disconnect |
| 15025 | logical conn connection encrypt error |
| 15026 | logical conn connection decrypt error |
| 15027 | logical conn upgrade need depends |
| 15028 | logical conn already upgraded |
| 15029 | logical conn device not matched |
| 15030 | logical conn account changed |
| 15031 | logical conn trust group changed |
| 15032 | logical conn upgrade not supported |
| 15033 | logical conn remote confirm timeout |
| 15034 | logical conn local confirm timeout |
| 15035 | logical conn p2p created by other |
| 15036 | logical conn device not reachable |
| 15037 | logical conn local active disconnect |
| 15038 | logical conn server stopped |
| 15039 | logical conn heartbeat timeout |
| 15040 | logical conn proto not handled |
| 15041 | logical conn local conflict |
| 15042 | logical conn conflict but can be retried |
| 15043 | logical conn address direct connection is not supported |
| 15044 | logical conn link address changed |
| 15045 | logical conn conflict but can wait |
| 15046 | logical conn request link timeout |
| 15047 | logical conn service name has too much conn |
| 15048 | logical conn remote conflict |
| 15049 | logical conn too much communication link |
| 15050 | logical conn wait for connecting |
| 15051 | logical conn wait for prev disconnected |
| 15052 | logical conn wait |
| 15053 | logical conn userspace background |
| 15054 | logical conn bt too much |
| 15055 | logical conn medium manual disabled |
| 15056 | logical conn medium type disable |
| 15057 | logical conn req medium no addr other medium reachable |
| 15058 | logical conn cannot create or reuse |
| 15059 | logical conn timeout while auth |
| 15060 | logical conn timeout while upgrade |
| 15061 | logical conn exclusive but no addr |
| 15062 | logical conn not have valid network |
| 15063 | logical conn remote net disconnected |
| 15064 | logical conn remote net not connected |
| 15065 | logical conn not invalid phys id |
| 15066 | logical conn not support tcp tunnel |
| 15067 | logical conn not support udp tunnel |
| 15068 | logical conn mijia relation changed |
| 15069 | logical conn medium does not support tunnel |
| 15070 | logical conn ble is not supported when screen is off |
| 15071 | logical conn secret decrypt failed |

## Physical Connection Errors (16001-16053)

| Code | Description |
|------|-------------|
| 16001 | physical conn failed |
| 16002 | physical conn invalid param |
| 16003 | physical conn invalid data |
| 16004 | physical conn invalid operate |
| 16005 | physical conn not init |
| 16006 | physical conn timeout |
| 16007 | physical conn exception |
| 16008 | physical conn no account |
| 16009 | physical conn no memory |
| 16010 | physical conn out of memory |
| 16011 | physical conn conflict service name |
| 16012 | physical conn create server failed |
| 16013 | physical conn server is stopping |
| 16014 | physical conn not support medium type |
| 16015 | physical conn create trans server failed |
| 16016 | physical conn duplicate connection |
| 16017 | physical conn not connected |
| 16018 | physical conn invalid physical id |
| 16019 | physical conn invalid link id |
| 16020 | physical conn invalid trans id |
| 16021 | physical conn invalid trans address |
| 16022 | physical conn invalid protocol |
| 16023 | physical conn max connection |
| 16024 | physical conn max payload length |
| 16025 | physical conn invalid server id |
| 16026 | physical conn server not started |
| 16027 | physical conn terminated |
| 16028 | physical conn is closing |
| 16029 | physical conn not available |
| 16030 | physical conn invalid medium info |
| 16031 | physical conn trans breakage |
| 16032 | physical conn heartbeat timeout |
| 16033 | physical conn local active close |
| 16034 | physical conn remote active close |
| 16035 | physical conn server stopped |
| 16036 | physical conn forbidden medium type |
| 16037 | physical conn unknown medium type |
| 16038 | physical conn medium type disable |
| 16039 | physical conn power system suspend |
| 16040 | physical conn peer medium type disable |
| 16041 | physical conn ap not started |
| 16042 | physical conn userspace changed |
| 16043 | physical conn medium manual disabled |
| 16044 | physical conn depend conn disconnected |
| 16045 | physical conn power shutdown |
| 16046 | physical conn medium type closed |
| 16047 | physical conn not same network area |
| 16048 | physical conn network client removed |
| 16049 | physical conn disconnect on sleep mode |
| 16050 | physical conn disconnect on screen off |
| 16051 | physical conn disconnect on app window hidden |
| 16052 | physical conn disconnect on cellular off |
| 16053 | physical conn disconnect on wlan or eth off |

## Link Manager Errors (17001-17032)

| Code | Description |
|------|-------------|
| 17001 | link manager default error |
| 17002 | link type error |
| 17003 | link type is not server |
| 17004 | link type is not client |
| 17005 | link id is already in use |
| 17006 | link type is not supported |
| 17007 | link radio is off |
| 17008 | link id is not a valid |
| 17009 | link point has no info |
| 17010 | link point has no config |
| 17011 | link point can not destroy |
| 17012 | link point can not disconnect |
| 17013 | link has no ability |
| 17014 | link wifi info error |
| 17015 | link bt info error |
| 17016 | link config type error |
| 17017 | link info reuse |
| 17018 | link server already stopped |
| 17019 | link server used by other |
| 17020 | link server not found |
| 17021 | link invalid param |
| 17022 | link server double destroy |
| 17023 | link server create aborted |
| 17024 | link server connect aborted |
| 17025 | link client not found |
| 17026 | link server double disconnect |
| 17027 | link server connected by other |
| 17028 | link server not created |
| 17029 | link invalid server status |
| 17030 | link api not supported |
| 17031 | link ap type not supported |
| 17032 | link server switch channel failed |

## Transport Manager Errors (18001-18013)

| Code | Description |
|------|-------------|
| 18001 | trans_m general error |
| 18002 | trans_m invalid param |
| 18003 | trans_m invalid data |
| 18004 | trans_m invalid operate |
| 18005 | trans_m no channel |
| 18006 | trans_m cipher failed |
| 18013 | trans_m not support |

## Transport Errors (19001-19015)

| Code | Description |
|------|-------------|
| 19001 | trans failed |
| 19002 | trans invalid param |
| 19003 | trans invalid data |
| 19004 | trans invalid operate |
| 19005 | trans socket error |
| 19006 | trans timeout |
| 19007 | trans invalid handle |
| 19008 | trans unknown protocol |
| 19009 | trans no memory |
| 19010 | trans data len error |
| 19011 | trans private protocol error |
| 19012 | trans channel not connected |
| 19013 | trans channel terminated |
| 19014 | trans data too long |
| 19015 | trans data too much |

## Invite Errors (20001-20012)

| Code | Description |
|------|-------------|
| 20001 | invite failed |
| 20002 | invite invalid param |
| 20003 | invite invalid data |
| 20004 | invite invalid operate |
| 20005 | invite not init |
| 20006 | invite timeout |
| 20007 | invite no memory |
| 20008 | invite out of memory |
| 20009 | invite no connection address |
| 20010 | invite not support medium type |
| 20011 | invite serialize failed |
| 20012 | invite deserialize failed |

## Device Errors (21001-21010)

| Code | Description |
|------|-------------|
| 21001 | device failed |
| 21002 | device invalid param |
| 21003 | device invalid data |
| 21004 | device invalid operate |
| 21005 | device not init |
| 21006 | device not exist |
| 21007 | device no link addr |
| 21008 | device same link addr |
| 21009 | device invalid device id |
| 21010 | device invalid range type |

## BLE Errors (22001-22140)

| Code | Description |
|------|-------------|
| 22001 | ble failed |
| 22002 | ble invalid param |
| 22003 | ble invalid data |
| 22004 | ble invalid operate |
| 22005 | ble not init |
| 22006 | ble connect timeout |
| 22007 | ble already init |
| 22008 | ble device not connect |
| 22009 | ble no memory |
| 22010 | ble no permission |
| 22011 | ble unauthorized |
| 22012 | ble not support |
| 22013 | ble internal error |
| 22014 | ble start gatt server fail |
| 22015 | ble stop gatt server fail |
| 22016 | ble add service fail |
| 22017 | ble remove service fail |
| 22018 | ble connect gatt server fail |
| 22019 | ble disconnect gatt server fail |
| 22020 | ble disconnect gatt client fail |
| 22021 | ble send data fail |
| 22022 | ble system wrapper error |
| 22023 | ble bluetooth service exception |
| 22024 | ble bluetooth adapter exception |
| 22025 | ble scan failed |
| 22026 | ble scanner null |
| 22027 | ble advertiser null |
| 22028 | ble above max number |
| 22029 | ble parameter exception |
| 22030 | ble advertising data error |
| 22031 | ble handle not advertising |
| 22032 | ble gatt client null |
| 22033 | ble mtu size error |
| 22034 | ble exchange mtu failed |
| 22035 | ble discover service failed |
| 22036 | ble notify character failed |
| 22037 | ble write character failed |
| 22038 | ble set notify failed |
| 22039 | ble gatt service null |
| 22040 | ble character null |
| 22041 | ble gatt client connect fail |
| 22042 | ble gatt server null |
| 22043 | ble add character failed |
| 22044 | ble open gatt server failed |
| 22045 | ble unknown service uuid |
| 22046 | ble too large data |
| 22047 | ble notify character unknown |
| 22048 | ble server service null |
| 22049 | ble already set |
| 22050 | ble bluetooth is off now |
| 22051 | ble chip lost data |
| 22052 | ble send busy |
| 22053 | ble already start scan |
| 22054 | ble illegal state |
| 22055 | ble client descriptor null |
| 22056 | ble background scan service bound |
| 22057 | ble background scan service not bound |
| 22058 | ble background scan service security exception |
| 22059 | ble too many advertisers |
| 22060 | ble already start advertising |
| 22061 | ble scan application registration failed |
| 22062 | ble scan out of hardware resources |
| 22063 | ble scan start too frequently |
| 22064 | ble gatt insufficient encryption |
| 22065 | ble scan out of hardware resources |
| 22066 | ble scan out of hardware resources |
| 22067 | ble scan out of hardware resources |
| 22068 | ble already create trans server |
| 22069 | ble trans governor already connect server |
| 22070 | ble connecting |
| 22071 | ble disconnecting |
| 22072 | ble adv extend parameter exception |
| 22073 | ble adv extend fail |
| 22074 | ble adv callback is null |
| 22075 | ble adv id not found |
| 22076 | ble send data failed due to restrict |
| 22077 | ble send data not allow in restrict |
| 22078 | ble already connected |
| 22079 | ble connected device not in list |
| 22080 | ble connection callback is null |
| 22081 | ble connection connect gatt timeout |
| 22082 | ble connection discovery service timeout |
| 22083 | ble connection exchange mtu timeout |
| 22084 | ble connection write descriptor timeout |
| 22085 | ble gatt local framework or stack error |
| 22086 | ble connection write descriptor fail |
| 22087 | ble connection fail for active disconnect |
| 22088 | ble payload callback is null |
| 22089 | ble connection no connect service request |
| 22090 | ble scan callback is null |
| 22091 | ble scan fail for active stop |
| 22092 | ble connection default error code |
| 22093 | ble discovery default error code |
| 22094 | ble disconnect by rf keep connection timeout |
| 22095 | ble disconnect by remote |
| 22096 | ble disconnect by remote low resources |
| 22097 | ble disconnect by remote bluetooth off |
| 22098 | ble disconnect by local |
| 22099 | ble disconnect by ll rsp timeout |
| 22100 | ble hardware failure |
| 22101 | ble bluetooth hci error |
| 22102 | ble gatt write not permitted |
| 22103 | ble gatt read not permitted |
| 22104 | ble establish connection timeout |
| 22105 | ble connection connect gatt fail |
| 22106 | ble connection trans breakage |
| 22107 | ble connection trans timeout |
| 22108 | ble connection trans terminated |
| 22109 | ble jni null |
| 22110 | ble l2cap start server failed |
| 22111 | ble l2cap conn server failed |
| 22112 | ble l2cap above max number |
| 22113 | ble l2cap conn object null |
| 22114 | ble l2cap server socket null |
| 22115 | ble l2cap server accept error |
| 22116 | ble l2cap exception |
| 22117 | ble socket invalid ble address |
| 22118 | ble gatt null failed |
| 22119 | ble l2cap gatt disconnect |
| 22120 | ble l2cap connecting |
| 22121 | ble l2cap device not connected |
| 22122 | ble l2cap send busy |
| 22123 | ble l2cap already connected |
| 22124 | ble l2cap disconnecting |
| 22125 | ble l2cap conn fail for active disconnect |
| 22126 | ble l2cap conn failed |
| 22127 | ble l2cap conn no connect service request |
| 22128 | ble l2cap conn connect service fail |
| 22129 | ble write failure |
| 22130 | ble socket write failed due to restrict |
| 22131 | ble gatt conn fail for acl disconnect |
| 22132 | ble gatt conn fail for device is disconnected |
| 22133 | ble gatt conn fail for request connect service timeout |
| 22134 | ble socket conn fail for timeout |
| 22135 | ble connect gatt server timeout |
| 22136 | ble get remote device fail |
| 22137 | ble conn fail for not connected with service |
| 22138 | ble l2cap disconnected |
| 22139 | ble l2cap conn exception and closed |
| 22140 | ble connect timeout after retry |

## Classic Bluetooth Errors (23001-23088)

| Code | Description |
|------|-------------|
| 23001 | bt failed |
| 23002 | bt invalid param |
| 23003 | bt invalid data |
| 23004 | bt invalid operate |
| 23005 | bt not init |
| 23006 | bt connection fail for timeout |
| 23007 | bt already init |
| 23008 | bt device not connect |
| 23009 | bt no memory |
| 23010 | bt no permission |
| 23011 | bt unauthorized |
| 23012 | bt not support |
| 23013 | bt internal error |
| 23014 | bt start rfcomm server fail |
| 23015 | bt stop rfcomm server fail |
| 23016 | bt write failed due to restrict state limited |
| 23017 | bt device null |
| 23018 | bt connect rfcomm server fail |
| 23019 | bt disconnect rfcomm server fail |
| 23020 | bt disconnect rfcomm client fail |
| 23021 | bt connection object null |
| 23022 | bt system wrapper error |
| 23023 | bt bluetooth service exception |
| 23024 | bt bluetooth adapter exception |
| 23025 | bt rfcomm server accept error |
| 23026 | bt jni null |
| 23027 | bt advertiser null |
| 23028 | bt above max number |
| 23029 | bt parameter exception |
| 23030 | bt address invalid |
| 23031 | bt read or write socket thrown ioexception |
| 23032 | bt gatt client null |
| 23033 | bt mtu size error |
| 23034 | bt exchange mtu failed |
| 23035 | bt discover service failed |
| 23036 | bt notify character failed |
| 23037 | bt write character failed |
| 23038 | bt set notify failed |
| 23039 | bt gatt service null |
| 23040 | bt character null |
| 23041 | bt gatt client connect fail |
| 23042 | bt gatt server null |
| 23043 | bt add character failed |
| 23044 | bt open gatt server failed |
| 23045 | bt unknown service uuid |
| 23046 | bt too large data |
| 23047 | bt notify character unknown |
| 23048 | bt server socket null |
| 23049 | bt already set |
| 23050 | bt bluetooth is off now |
| 23051 | bt thread not lyra thread, can not PostTask |
| 23052 | bt send busy |
| 23053 | bt already start scan |
| 23054 | bt illegal state |
| 23055 | bt client descriptor null |
| 23056 | bt background scan service bound |
| 23057 | bt background scan service not bound |
| 23058 | bt background scan service security exception |
| 23059 | bt too many advertisers |
| 23060 | bt already start advertising |
| 23061 | bt scan application registration failed |
| 23062 | bt scan out of hardware resources |
| 23063 | bt scan start too frequently |
| 23064 | bt gatt insufficient encryption |
| 23065 | bt scan out of hardware resources |
| 23066 | bt scan out of hardware resources |
| 23067 | bt scan out of hardware resources |
| 23068 | bt already create trans server |
| 23069 | bt trans governor already connect server |
| 23070 | bt connecting |
| 23071 | bt disconnecting |
| 23072 | bt already connected |
| 23073 | bt connection callback is null |
| 23074 | bt payload callback is null |
| 23075 | bt connection no connect service request |
| 23076 | bt connection connect service fail |
| 23077 | bt connection fail for active disconnect |
| 23078 | bt connection default error code |
| 23079 | bt hfp or a2dp connected |
| 23080 | bt hfp or a2dp not connected |
| 23081 | bt hfp or a2dp not support |
| 23082 | bt connection trans breakage |
| 23083 | bt connection trans timeout |
| 23084 | bt connection trans terminated |
| 23085 | bt miwear spp not connect |
| 23086 | bt connection fail for disconnected |
| 23087 | bt conn exception and closed |
| 23088 | bt conn timeout after retry |

## MISS Errors (24001-24015)

| Code | Description |
|------|-------------|
| 24001 | miss invalid param |
| 24002 | miss client init failed |
| 24003 | miss session open failed |
| 24004 | miss rpc send callback failed |
| 24005 | miss invalid handle |
| 24006 | miss failed |
| 24007 | miss not init |
| 24008 | miss client already started |
| 24009 | miss server already started |
| 24010 | miss send failed |
| 24011 | miss close failed |
| 24012 | miss server init failed |
| 24013 | miss configure file error |
| 24014 | miss server rpc process error |
| 24015 | miss client connect failed |

## mDNS Errors (25001-25005)

| Code | Description |
|------|-------------|
| 25001 | mdns failed |
| 25002 | mdns invalid param |
| 25003 | mdns invalid data |
| 25004 | mdns invalid operate |
| 25005 | mdns not init |

## WiFi Errors (26001-26021)

| Code | Description |
|------|-------------|
| 26001 | wifi disable |
| 26002 | wifi location off |
| 26003 | wifi permission lost |
| 26004 | wifi failed |
| 26005 | wifi timeout |
| 26006 | wifi busy |
| 26007 | wifi invalid param |
| 26008 | wifi invalid operation |
| 26009 | wifi p2p in used |
| 26010 | wifi p2p not init |
| 26011 | wifi station in used |
| 26012 | wifi station not init |
| 26013 | wifi local ap in used |
| 26014 | wifi ap not init |
| 26015 | wifi remote ap in used |
| 26016 | wifi trans breakage |
| 26017 | wifi trans timeout |
| 26018 | wifi trans terminated |
| 26019 | wifi p2p set option failed |
| 26020 | wifi conn timeout after retry |
| 26021 | wifi user denied |

## Storage Errors (27001-27010)

| Code | Description |
|------|-------------|
| 27001 | storage failed |
| 27002 | storage invalid param |
| 27003 | storage invalid data |
| 27004 | storage invalid operate |
| 27005 | storage not init |
| 27006 | storage encode failed |
| 27007 | storage decode failed |
| 27008 | storage write file failed |
| 27009 | storage read file failed |
| 27010 | storage mac address get failed |

## System Errors (28001-28006)

| Code | Description |
|------|-------------|
| 28001 | system failed |
| 28002 | system invalid param |
| 28003 | system invalid data |
| 28004 | system invalid operate |
| 28005 | system not init |
| 28006 | system no memory |

## Auth Errors (29001-29091)

| Code | Description |
|------|-------------|
| 29001 | auth failed |
| 29002 | auth invalid param |
| 29003 | auth not init |
| 29004 | auth communication error |
| 29005 | auth timeout |
| 29031 | auth incorrect pincode |
| 29061 | auth not same account |
| 29062 | auth local cert invalid |
| 29063 | auth peer cert invalid |
| 29091 | auth not paired |

## Crypto Errors (30001-30002)

| Code | Description |
|------|-------------|
| 30001 | crypto invalid param |
| 30002 | crypto encrypt failed |

## Permission Errors (31001-31010)

| Code | Description |
|------|-------------|
| 31001 | permission ble adv denied |
| 31002 | permission ble disc denied |
| 31003 | permission mdns adv denied |
| 31004 | permission mdns disc denied |
| 31005 | permission bt denied |
| 31006 | permission wifi denied |
| 31007 | permission p2p denied |
| 31008 | permission failed |
| 31009 | permission parse file failed |
| 31010 | permission unsupport json version |

## Account Errors (32001-32011)

| Code | Description |
|------|-------------|
| 32001 | account failed |
| 32002 | account invalid param |
| 32003 | account not init |
| 32004 | account delete device not login |
| 32005 | account delete device failed |
| 32006 | account ot create socket failed |
| 32007 | account connect ot client failed |
| 32008 | account ot create epoll failed |
| 32009 | account ot invalid json |
| 32010 | account ot send message failed |
| 32011 | dmsdk channel not opened |

## KCP Errors (33001-33020)

| Code | Description |
|------|-------------|
| 33001 | kcp failed |
| 33002 | kcp invalid param |
| 33003 | kcp invalid data |
| 33004 | kcp invalid operate |
| 33005 | kcp socket error |
| 33006 | kcp trans timeout |
| 33007 | kcp invalid handle |
| 33008 | kcp unknown protocol |
| 33009 | kcp no memory |
| 33010 | kcp data len error |
| 33011 | kcp private protocol error |
| 33012 | kcp channel not connected |
| 33013 | kcp channel terminated |
| 33014 | kcp data too long |
| 33015 | kcp data too much |
| 33016 | kcp trans breakage |
| 33017 | kcp trans terminated |
| 33018 | kcp trans dead |
| 33019 | kcp timeout after retry |
| 33020 | kcp trans fast timeout |

## NFC Errors (34001-34007)

| Code | Description |
|------|-------------|
| 34001 | nfc failed |
| 34002 | nfc listener has registered |
| 34003 | nfc listener not registered |
| 34004 | nfc duplicated init |
| 34005 | nfc service exception |
| 34006 | nfc register listener can not be null |
| 34007 | nfc unregister listener can not be null |

## Event Errors (35001-35005)

| Code | Description |
|------|-------------|
| 35001 | event failed |
| 35002 | event filter is empty |
| 35003 | event listener has registered |
| 35004 | event listener not exist |
| 35005 | event param is invalid |

## P2P Negotiation Errors (36001-36022)

| Code | Description |
|------|-------------|
| 36001 | p2p nego server type is mismatched |
| 36002 | p2p nego server client cannot coexist |
| 36003 | p2p nego server accept client limit |
| 36004 | p2p nego client type is mismatched |
| 36005 | p2p nego client cannot connect multi server |
| 36006 | p2p nego client server cannot coexist |
| 36007 | p2p nego both client and server type is mismatched |
| 36008 | p2p nego serv type mismatch and client cannot connect mult serv |
| 36009 | p2p nego server type mismatch and client server cannot coexist |
| 36010 | p2p nego serv cli cannot coexist and cli type is mismatched |
| 36011 | p2p nego serv cli cannot coex and cli cannot connect mult serv |
| 36012 | p2p nego serv cli cannot coex and cli server cannot coex |
| 36013 | p2p nego serv accept cli limit and cli type is mismatched |
| 36014 | p2p nego serv accept cli limit and cli cannot connect mult serv |
| 36015 | p2p nego serv accept cli limit and cli serv cannot coexist |
| 36016 | p2p nego network card type mismatch |
| 36017 | p2p nego trans mode type mismatch |
| 36018 | p2p nego wifi capability not supported |
| 36019 | p2p nego not supported for local only |
| 36020 | p2p nego network card does not support role type |
| 36021 | p2p nego no available roles after filter remote |
| 36022 | p2p nego trans mode not support role type |

## QoS Errors (37001-37060)

| Code | Description |
|------|-------------|
| 37001 | qos unknown error |
| 37002 | qos err p2p conflict |
| 37003 | qos err invalid cmd |
| 37004 | qos err invalid param |
| 37005 | qos err record not exist |
| 37006 | qos err medium is not supported |
| 37007 | qos err wifi is turned off |
| 37008 | qos err module uninitialized |
| 37009 | qos err call lyra func fail |
| 37010 | qos err unreachable |
| 37011 | qos err p2p conflict with 3rd app |
| 37012 | qos err p2p conflict with 3rd app |
| 37013 | qos err p2p exceed max size |
| 37030 | qos err p2p conflict with 3rd app |
| 37031 | qos err p2p conflict p2p used |
| 37032 | qos err p2p conflict hotspot used |
| 37033 | qos err p2p conflict with aware |
| 37034 | qos err aware conflict with p2p |
| 37060 | qos err exceed max connection size |

## JNI Errors (51001-51003)

| Code | Description |
|------|-------------|
| 51001 | jni check failed |
| 51002 | jni parse error |
| 51003 | jni failed |

## Channel Errors (52001-52022)

These are the most commonly encountered errors when using the Channel SDK directly.

| Code | Description |
|------|-------------|
| 52001 | channel failed |
| 52002 | channel invalid param |
| 52003 | channel invalid data |
| 52004 | channel invalid operate |
| 52005 | channel not connected |
| 52006 | channel invalid port |
| 52007 | channel server conflict |
| 52008 | channel negotiate timeout |
| 52009 | channel request port timeout |
| 52010 | channel unsupport send |
| 52011 | channel peer sdk release |
| 52012 | channel invalid class type |
| 52013 | channel invalid id |
| 52014 | channel destroy manually |
| 52015 | channel not init |
| 52016 | channel remove server |
| 52017 | channel invalid service |
| 52018 | channel invalid key |
| 52019 | channel mismatch trust_level |
| 52020 | channel not support |
| 52021 | channel msg too big |
| 52022 | channel not support remote connection |

## Networking Worker Errors (53001-53024)

| Code | Description |
|------|-------------|
| 53001 | networking worker failed |
| 53002 | networking invalid param |
| 53003 | networking device not exist |
| 53004 | networking device connection not exist |
| 53005 | networking payload invalid param |
| 53006 | networking payload reach limit |
| 53007 | networking auth null pointer |
| 53008 | networking auth start server failed |
| 53009 | networking auth refuse bind request |
| 53010 | networking no group invalid param |
| 53011 | networking no group started |
| 53012 | networking no group not ready |
| 53013 | networking add service repeat |
| 53014 | networking remove service not exist |
| 53015 | networking disconnect |
| 53016 | networking discovery not init |
| 53017 | networking advertising not init |
| 53018 | networking advertising invalid param |
| 53019 | networking not started |
| 53020 | networking not support slave device |
| 53021 | networking not init |
| 53022 | networking not support |
| 53023 | networking remote auth client failed |
| 53024 | networking remote auth server failed |

## Message Center Errors (54001-54025)

| Code | Description |
|------|-------------|
| 54001 | message-center failed |
| 54002 | message-center invalid param |
| 54003 | message-center invalid data |
| 54004 | message-center not init |
| 54005 | message-center listener add failed |
| 54006 | message-center no online device |
| 54007 | message-center publish message error |
| 54008 | message-center secret encrypt failed |
| 54009 | message-center secret decrypt failed |
| 54010 | message-center topic name not support |
| 54011 | message-center get key failed |
| 54012 | message-center refresh key failed |
| 54013 | message-center data parser failed |
| 54014 | message-center un publish remain drop |
| 54015 | message-center load rules failed |
| 54016 | message-center matched rules failed |
| 54017 | message-center create channel failed |
| 54018 | message-center rule invalid |
| 54019 | message-center action invalid |
| 54020 | message-center medium type invalid |
| 54021 | message-center userspace changed |
| 54022 | message-center topic not clear |
| 54023 | message-center topic illegal |
| 54024 | message-center repeated operation |
| 54025 | message-center match send type failed |

---

## MiWear Errors (81001-89007)

### MiWear API Errors (81001-81008)

| Code | Description |
|------|-------------|
| 81001 | miwear api failed |
| 81002 | miwear api invalid param |
| 81003 | miwear api invalid operate |
| 81004 | miwear api not init |
| 81005 | miwear api no memory |
| 81006 | miwear api out of memory |
| 81007 | miwear api no permission |
| 81008 | miwear api not support operate |

### MiWear Core Errors (82001-82007)

| Code | Description |
|------|-------------|
| 82001 | miwear core failed |
| 82002 | miwear core invalid param |
| 82003 | miwear core invalid operate |
| 82004 | miwear core no memory |
| 82006 | miwear core not support |
| 82007 | miwear core jni failed |

### MiWear Device Errors (83001-83004)

| Code | Description |
|------|-------------|
| 83001 | miwear device failed |
| 83002 | miwear device invalid param |
| 83003 | miwear device invalid operate |
| 83004 | miwear device not exist |

### MiWear Discovery Errors (85001-85005)

| Code | Description |
|------|-------------|
| 85001 | miwear discovery failed |
| 85002 | miwear discovery invalid param |
| 85003 | miwear discovery invalid operate |
| 85004 | miwear discovery not support |
| 85005 | miwear discovery not init |

### MiWear Channel Errors (87001-87016)

| Code | Description |
|------|-------------|
| 87001 | miwear channel failed |
| 87002 | miwear channel invalid param |
| 87003 | miwear channel invalid data |
| 87004 | miwear channel invalid operate |
| 87005 | miwear channel conflict operate |
| 87006 | miwear channel not init |
| 87007 | miwear channel not support |
| 87008 | miwear channel no memory |
| 87009 | miwear channel trans breakage |
| 87010 | miwear channel device lost |
| 87011 | miwear channel channel id not exist |
| 87012 | miwear channel service name not exist |
| 87013 | miwear channel timeout |
| 87014 | miwear channel local confirm timeout |
| 87015 | miwear channel remote confirm timeout |
| 87016 | miwear channel local confirm reject |

### MiWear Net Errors (88001-88004)

| Code | Description |
|------|-------------|
| 88001 | miwear net failed |
| 88002 | miwear net not online |
| 88003 | miwear net not support lyra |
| 88004 | miwear net not init |

### MiWear Message Errors (89001-89007)

| Code | Description |
|------|-------------|
| 89001 | miwear message failed |
| 89002 | miwear message invalid param |
| 89003 | miwear message invalid data |
| 89004 | miwear message invalid operate |
| 89005 | miwear message not init |
| 89006 | miwear message not support |
| 89007 | miwear message no memory |

---

## SDK Runtime Errors

These errors are returned at the SDK service layer (Java/Android side).

### Common Errors

| Code | Description |
|------|-------------|
| 1000000 | common failed |
| 1010001 | runtime timeout |
| 1010002 | runtime not found |
| 1010003 | runtime exception |
| 1010004 | appInfo is null |
| 1010005 | duplicate operation |
| 1030000 | pkg is null |
| 1031000 | trust level is too low |
| 1400001 | api not support |

### Permission Errors (Negative Codes)

| Code | Description |
|------|-------------|
| -1001000 | permission denied for BLE advertising |
| -1002000 | permission denied for BLE discovery |
| -1003000 | permission denied for mdns advertise |
| -1004000 | permission denied for mdns discovery |
| -1005000 | permission denied for bt |
| -1006000 | permission denied for wifi |
| -1007000 | permission denied for p2p |
| -1008000 | permission denied, need in-process call |
| -1009000 | permission denied for lyra customizing PERMISSION |
| -1010000 | permission denied for get address by this mediumType |
| -1011000 | permission denied for get address by this prop |

### Data Transfer Runtime Errors

| Code | Description |
|------|-------------|
| 1101000 | bind lyra service |
| 1102000 | destroy channel success |
| 1103000 | never registered |
| 1104000 | miui opt not enable |
| -1 | parameter error |
| -2 | app info is null |
| -3 | service died |
| -4 | no api feature for runtime |
| -5 | p2p lock failed |
| 3001000 | sdk service died |

### Networking Service Runtime Errors

| Code | Description |
|------|-------------|
| 1301000 | networking listener has been added |
| 1302000 | networking service exception |
| 1303000 | networking executor exception |

### Message Service Runtime Errors

| Code | Description |
|------|-------------|
| 1201000 | bindService failed |
| 1202000 | runtime service exception |
| 3101000 | no permission to call this method |
| 3102000 | subscribe duplicate registration |
| 3103000 | please subscribe before you can unsubscribe |
| 3104000 | publish messages that exceed the stated limit |
| 3105000 | get fitable mtu error |
| 3106000 | handle share memory error |
| 3107000 | error: big data length is 0 |
| 3108000 | local lyra runtime not support publish big data prop |
| 3109000 | duplicate operation |
| 3110000 | invalid operation |

### MixChannel Errors

| Code | Description |
|------|-------------|
| 1601000 | mix channel common error |
| 1601001 | internal error |
| 1601002 | invalid mix-channel id |
| 1601003 | mix-channel not exists |
| 1601004 | non active channel |
| 1601005 | sub channel not exist |
| 1601006 | invalid parameter |
| 1601007 | duplicate medium type |
| 1601008 | channel released |
| 1601009 | method unimplemented |
| 1601010 | protocol error |
| 1601011 | protocol len mismatch |
| 1601012 | protocol overflow |
