import {
  Any,
  BasicMessageChannel,
  FlutterPlugin,
  Log,
  StandardMessageCodec
} from '@ohos/flutter_ohos';
import { FlutterPluginBinding } from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import { Reply } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BasicMessageChannel';
import { getDeeplinkUri } from './GlobalState';
import { uri } from '@kit.ArkTS';

const TAG = 'DeepLinkPlugin';

export default class DeepLinkPlugin implements FlutterPlugin {
  private static channelName = 'samples.flutter.dev/deeplink_channel';
  private basicChannel?: BasicMessageChannel<Any>;

  private static currentChannel?: BasicMessageChannel<Any>;

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    Log.i(TAG, 'onAttachedToEngine');

    this.basicChannel = new BasicMessageChannel<Any>(
      binding.getBinaryMessenger(),
      DeepLinkPlugin.channelName,
      new StandardMessageCodec()
    );

    DeepLinkPlugin.currentChannel = this.basicChannel;

    this.basicChannel.setMessageHandler({
      onMessage(message: Any, reply: Reply<Any>) {
        Log.i(TAG, `Flutter requested URI: ${message}`);
        reply.reply(getDeeplinkUri());
      }
    });
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    Log.i(TAG, 'onDetachedFromEngine');
    this.basicChannel?.setMessageHandler(null);
    DeepLinkPlugin.currentChannel = undefined;
  }

  getUniqueClassName(): string {
    return 'DeepLinkPlugin';
  }

  /**
   * Harmony App 启动时可调用此方法，将 want.uri 主动推送给 Flutter。
   */
  static sendDeeplink(uri: string): void {
    if (DeepLinkPlugin.currentChannel) {
      Log.i(TAG, 'Sending URI to Flutter: ' + uri);
      /// https://cagayan.digital/?code=pre_0082482f-732e-438c-b56b-55c96d97a2a1&fallback=https://apkstatic.s3.ap-southeast-1.amazonaws.com/burst_hue_v1.4.6_2.apk&lang=zh_CN
      /// dragonfly://home?code=pre_0082482f-732e-438c-b56b-55c96d97a2a1
      ///

      DeepLinkPlugin.currentChannel.send(DeepLinkPlugin.convertToDragonflyLink(uri));
    } else {
      Log.w(TAG, 'DeepLinkPlugin not yet attached, unable to send deeplink.');
    }
  }

  static convertToDragonflyLink(inputUrl: string): string {
    try {
      const urlStr: uri.URI = new uri.URI(inputUrl);
      if(urlStr.scheme == 'dfbmi')  return inputUrl;
      let query = urlStr.query;
      // let code = urlStr.getQueryValue('code');

      return 'dfbmi://home?${query}';
    } catch (error) {
      console.error('Invalid URL:', error);
      return inputUrl;
    }
  }
}
