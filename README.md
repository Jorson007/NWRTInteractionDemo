# NWRTInteractionDemo
基于MQTT的实时互动Demo  

使用说明：
1.拉取代码后进入文件夹执行pod install安装MQTT和AFNetworking SDK  运行demo，  2.进入登录页，当前用户名只支持（user1 , user2 ,user3）这三个，密码都是123456.  
  3.登录进去之后，点击添加按钮可以新增图形，拖动图形可以移动图形的位置，如果此时另外一个模拟器上运行着app且用户名与该模拟器上的用户名不一样，则可以进行同步；  
  4.点击清空可以清除界面上的所有图形。  5.最多可以添加五个图形。

注：代码中设置为*****的地方涉及到环信消息云的账号和密码，请自行前往环信官网注册使用，参考文档：https://docs-im.easemob.com/mqtt/qsiossdk
