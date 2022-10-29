# MLeaksPing

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.


```ruby

    初始化组件
    
    [[MLeaksPing shared] handleLeaksType:(MLeaksHandleDebug) reportBlock:nil];
    [[MLeaksPing shared] setPongJudge:3];
    [[MLeaksPing shared] startPing];

    注意开发阶段使用，不必要跟随业务上线.
    
    尝试主动破解循环，目前支持不是太完美，但是基本可用
    如需要 `MLeaksHandleRelease` 请配合 `FBRetainCycleDetector` 打开相关屏蔽代码块，具体看 `MLeaksHandle`。
    
```

## Author

cocomanbar, 125322078@qq.com

## License

MLeaksPing is available under the MIT license. See the LICENSE file for more info.
