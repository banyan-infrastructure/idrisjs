module Js.ASync

import Effects
import public Js.Utils

%include JavaScript "js/async.js"
%include Node "js/async.js"

public export
data ASync : Type -> Type where
  MkASync : ((a -> JS_IO()) -> JS_IO ()) -> ASync a

export
setASync : (a -> JS_IO ()) -> ASync a -> JS_IO ()
setASync onEvent (MkASync set) =
  do
    set onEvent
    pure ()

export
setASync_ : ASync a -> JS_IO ()
setASync_ x = setASync (\_=>pure ()) x

export
total
setTimeout : Int -> a -> ASync a
setTimeout millis x =
  MkASync $ \onevt => assert_total $
    jscall  "setTimeout(%0, %1)" ( JsFn (() -> JS_IO ()) -> Int -> JS_IO ()) (MkJsFn $ \() => onevt x) millis

export
never : ASync a
never = MkASync (\onevt => pure ())

export
debugError : String -> ASync a
debugError s = MkASync (\_ => jscall "throw2(%0)" (String -> JS_IO ()) s)

export
liftJS_IO : JS_IO a -> ASync a
liftJS_IO x = MkASync (\onevt => x >>= onevt)

export
Functor ASync where
  map f (MkASync oldset) = MkASync (\onevt => oldset (\x => onevt (f x)) )

export
Applicative ASync where
  pure x = setTimeout 0 x
  (MkASync stepf) <*> (MkASync stepx) =
    MkASync (\onevt => stepf (\f => stepx (\x => onevt (f x)) ))

export
Monad ASync where
  (>>=) (MkASync stepx) f =
    MkASync $ \onevt => stepx (\x => let MkASync stepf = f x in stepf onevt )


export
data JSIOFifoQueue : (b : Type) -> Type where
  MkJSIOFifoQueue : Ptr -> JSIOFifoQueue a

export
newJSIOFifoQueue : (x : Type) -> JS_IO (JSIOFifoQueue x)
newJSIOFifoQueue _ =
  MkJSIOFifoQueue <$> jscall "{queue: [], callback: undefined}" (JS_IO Ptr)

export
putInQueue : a -> JSIOFifoQueue a -> JS_IO ()
putInQueue x (MkJSIOFifoQueue q) =
  jscall
    "$JSLIB$async.putInQueue(%0,%1)"
    (Ptr -> Ptr -> JS_IO ())
    (believe_me x)
    q

export
getQueuePtr : JSIOFifoQueue a -> Ptr
getQueuePtr (MkJSIOFifoQueue q) = q

export
getFromQueue : JSIOFifoQueue a -> ASync a
getFromQueue (MkJSIOFifoQueue q) =
  MkASync $ \proc =>
    believe_me <$>
      jscall
        "$JSLIB$async.getFromQueue(%0, %1)"
        (Ptr -> JsFn (Ptr -> JS_IO ()) -> JS_IO Ptr)
        q
        (MkJsFn (\x => proc $ believe_me x) )

export
implementation Handler Console ASync where
  handle () (Log s) k = do liftJS_IO $ jscall "console.log(%0)" (String -> JS_IO ()) s ; k () ()


{-
export
both : ASync a -> ASync a -> ASync a
both (MkASync s1) (MkASync s2) =
  MkASync $ \onevt =>
    do
      s1 onevt
      s2 onevt

export
data Cursor a = MkCursor (JS_IO ()) ((a -> JS_IO ()) -> JS_IO ())


export
Functor Cursor where
  map f (MkCursor c oe) = MkCursor c (\onevt => oe (\x => onevt (f x)) )


export
newCursor : (JS_IO ()) -> ((a -> JS_IO ()) -> JS_IO ()) -> Cursor a
newCursor c e = MkCursor c e

export
each : (a -> JS_IO ()) -> Cursor a -> JS_IO ()
each proc (MkCursor _ e) = e proc

export
close : Cursor a -> JS_IO ()
close (MkCursor x _) = x
-}
