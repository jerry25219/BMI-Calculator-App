

import { BasicMessageChannel, FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import window from '@ohos.window';
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { url } from '@kit.ArkTS';
import DeepLinkPlugin from './DeepLinkPlugin';
import { setDeeplinkUri } from './GlobalState';
import { BusinessError } from '@kit.BasicServicesKit';


export default class EntryAbility extends FlutterAbility {
  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine)
    this.addPlugin(new DeepLinkPlugin());
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    super.onWindowStageCreate(windowStage);
    windowStage.getMainWindow().then((data) => {
      data.setWindowKeepScreenOn(true, (err: BusinessError) => {
        const errCode: number = err.code;
        if (errCode) {
          console.error(`Failed to set the screen to be always on. Cause code: ${err.code}, message: ${err.message}`);
          return;
        }
        console.info('Succeeded in setting the screen to be always on.');
      });
    });
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    super.onCreate(want,launchParam);
    const uri = want?.uri;
    console.log('EntryAbility onCreate '+want.uri);
    if(uri) {
      setDeeplinkUri(uri);
      DeepLinkPlugin.sendDeeplink(uri);
    }
  }

  onNewWant(want: Want, launchParams: AbilityConstant.LaunchParam): void {
    super.onNewWant(want, launchParams);
    const uri = want?.uri;
    console.log('EntryAbility onCreate '+want.uri);
    if(uri) {
      setDeeplinkUri(uri);
      DeepLinkPlugin.sendDeeplink(uri);
    }
  }
}
