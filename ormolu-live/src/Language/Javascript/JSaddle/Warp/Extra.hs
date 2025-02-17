module Language.Javascript.JSaddle.Warp.Extra (run) where

#ifndef ghcjs_HOST_OS
import Language.Javascript.JSaddle.Run (syncPoint)
import Language.Javascript.JSaddle.Types (JSM)
import Language.Javascript.JSaddle.WebSockets
import qualified Network.Wai.Application.Static as WaiStatic
import qualified Network.Wai.Handler.Warp as Warp
import qualified Network.WebSockets as WS
#endif

#ifdef ghcjs_HOST_OS
run :: Int -> FilePath -> IO () -> IO ()
run _ _ = id
#else
run :: Int -> FilePath -> JSM () -> IO ()
run port dir f = do
  let staticApp = WaiStatic.staticApp $ WaiStatic.defaultFileServerSettings dir
      app = jsaddleAppWithJsOr (jsaddleJs False) staticApp
  app <- jsaddleOr WS.defaultConnectionOptions (f *> syncPoint) app
  Warp.runSettings (Warp.setPort port . Warp.setTimeout 3600 $ Warp.defaultSettings) app
#endif
