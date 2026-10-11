import SwiftUI
import WebKit

/// 把 https://nathanatgit.github.io/Shalielie/ 装进 App 的壳。
/// 网站本身是纯前端应用（HEIC 摄影风格移植），所有处理都在 WKWebView 里本地完成。
struct ContentView: View {
    static let siteURL = URL(string: "https://nathanatgit.github.io/Shalielie/")!

    var body: some View {
        StylePortWebView(url: Self.siteURL)
            .ignoresSafeArea()
    }
}

struct StylePortWebView: UIViewRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true

        // 下拉刷新：网页套壳 App 的刚需
        let refresh = UIRefreshControl()
        refresh.addTarget(context.coordinator, action: #selector(Coordinator.didPullToRefresh(_:)), for: .valueChanged)
        webView.scrollView.refreshControl = refresh
        context.coordinator.webView = webView

        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate {
        weak var webView: WKWebView?

        @objc func didPullToRefresh(_ sender: UIRefreshControl) {
            webView?.reload()
            // 页面开始加载后由 didFinish 结束；加个兜底避免转菊花卡住
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if sender.isRefreshing { sender.endRefreshing() }
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.scrollView.refreshControl?.endRefreshing()
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            webView.scrollView.refreshControl?.endRefreshing()
        }
    }
}
