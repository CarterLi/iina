//
//  DanmakuView.swift
//  iina
//
//  Created by  李通洲 on 2022/1/3.
//  Copyright © 2022 lhc. All rights reserved.
//

import Cocoa
import WebKit

class DanmakuView: WKWebView, WKNavigationDelegate {
  override func hitTest(_ point: NSPoint) -> NSView? {
    return nil
  }
}
