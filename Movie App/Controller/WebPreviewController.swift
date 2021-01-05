//
//  WebPreviewController.swift
//  Movie App
//
//  Created by Kaodim MacMini on 05/01/2021.
//

import Foundation
import UIKit
import WebKit

final class WebPreviewController: UIViewController {
    fileprivate var webView: WKWebView = {
        let webview = WKWebView()
        webview.isOpaque = false
        webview.backgroundColor = .white
        webview.scrollView.backgroundColor = .white
        return webview
    }()

    fileprivate let progressBar: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.progressTintColor = .red
        return progress
    }()

    fileprivate var url: URL?
    private var prefferedTitle: String?

    override fileprivate init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    convenience init(url: URL, prefferedTitle: String? = nil, stripeReturnUrl: String? = nil) {
        self.init()

        self.url = url
        self.prefferedTitle = prefferedTitle
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configureNavigationBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let siteURL = url {
            webView.frame = CGRect(origin: .zero,
                size: CGSize(width: view.bounds.width, height: view.bounds.height - (navigationController?.navigationBar.bounds.height ?? 0.0)))
            webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
            addWebViewWith(siteURL)
        } else {
            dismissView()
        }
    }

    deinit {
        if isViewLoaded {
            webView.removeObserver(self, forKeyPath: "estimatedProgress")
        }
        webView.navigationDelegate = nil
        webView.uiDelegate = nil
    }

    // swiftlint:disable block_based_kvo
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressBar.setProgress(Float(webView.estimatedProgress), animated: true)

            if webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
                    self.progressBar.alpha = 0
                }, completion: { _ in
                        self.progressBar.setProgress(0.0, animated: true)
                        self.progressBar.alpha = 1
                    })
            }
        } else {
            super.observeValue(forKeyPath: "estimatedProgress", of: object, change: change, context: context)
        }
    }

    fileprivate func configureNavigationBar() {
        title = prefferedTitle ?? (Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissView))
    }

    fileprivate func addWebViewWith(_ url: URL) {
        progressBar.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: view.bounds.width, height: 1.0))
        webView.addSubview(progressBar)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view.addSubview(webView)

        loadRequest(URLRequest(url: url))
    }

    private func loadRequest(_ request: URLRequest) {
        webView.load(request)
    }

    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }
}

extension WebPreviewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
    }

    func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
    }
}

extension WebPreviewController: WKUIDelegate {
    func webView(_: WKWebView, createWebViewWith _: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures _: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            loadRequest(navigationAction.request)
        }
        return nil
    }
}

extension UIViewController {
    func openUrl(urlStr: String, prefferedTitle: String? = nil) {
        guard let url = URL(string: urlStr) else { return }
        let webPreviewController = WebPreviewController(url: url, prefferedTitle: prefferedTitle)
        let navigationController = UINavigationController(rootViewController: webPreviewController)
        present(navigationController, animated: true, completion: nil)
    }
}
