module Js.HtmlUtils

import Js.HtmlTemplate
import Data.Vect

export
listCustomNS : String -> String -> List (BAttribute a f g) -> ((x:a) -> f x -> List (h x)) ->
                        BTemplate a h g -> BTemplate a f g
listCustomNS x = ListNode (Just x)

export
listCustom : String -> List (BAttribute a f g) -> ((x:a) -> f x -> List (h x)) ->
                        BTemplate a h g -> BTemplate a f g
listCustom = ListNode Nothing

namespace Dependent
  public export
  Template : (a:Type) -> (a->Type) -> (a->Type) -> Type
  Template = BTemplate

  public export
  Attribute : (a:Type) -> (a->Type) -> (a->Type) -> Type
  Attribute = BAttribute

  public export
  GuiRef : (a:Type) -> (a->Type) -> (a->Type)-> a -> Type
  GuiRef = BGuiRef

  export
  maybeOnSpanD : List (Attribute a f g) -> ((x:a)-> f x -> Maybe (h x)) -> BTemplate a h g -> BTemplate a f g
  maybeOnSpanD = MaybeNode "span"

  export
  listOnDivD : List (Attribute a f g) -> ((x:a) -> f x -> List (h x)) ->
                          BTemplate a h g -> BTemplate a f g
  listOnDivD = listCustom "div"

  export
  listOnDivIndexD : {h:a->Type} -> List (Attribute a f g) -> ((x:a) -> f x -> List (h x)) ->
                          BTemplate a (\x=> (Nat, h x)) g -> BTemplate a f g
  listOnDivIndexD attrs fn t = listOnDivD attrs (\x,y => let l = fn x y in zip [0..length l] l) t

  export
  vectOnDivIndex : {h:a->Type} -> List (Attribute a f g) -> (len : a->Nat) -> ((x:a) -> f x -> Vect (len x) (h x)) ->
                     BTemplate a (\x=>(Fin (len x), h x)) g -> BTemplate a f g
  vectOnDivIndex attrs len fn t = listOnDivD attrs (\x,y => let l = fn x y in toList $ zip range l) t

  export
  onclickD : ((x:a) -> f x -> g x) -> Attribute a f g
  onclickD = UnitEvent "click"

  export
  onchange : ((x:a) -> f x -> c x -> g x) -> InputAttribute a f g c
  onchange = OnChange

  export
  form : ((x:a) -> f x -> g x) -> List (Attribute a f g) -> List (BTemplate a f g) -> BTemplate a f g
  form = FormNode

  infixl 4 >$<, <$>

  export
  (>$<) : ((x:a) -> h x -> f x) -> Template a f g -> Template a h g
  (>$<) a b = CMapNode a b

  export
  (<$>) : ((x:a) -> h x -> g x) -> Template a f h -> Template a f g
  (<$>) a b = MapNode a b

  export
  setVal : ((x:a) -> f x -> Maybe (c x)) -> InputAttribute a f g c
  setVal = SetVal

namespace Simple
  public export
  Template : {t:Type} -> Type -> Type -> Type
  Template {t} b c = BTemplate t (const b) (const c)

  public export
  Attribute : {t:Type} -> Type -> Type -> Type
  Attribute {t} b c = Attribute t (const b) (const c)

  public export
  GuiRef : Type -> Type -> Type
  GuiRef b c = BGuiRef () (const b) (const c) ()


  export
  maybeOnSpan : {t:Type} -> List (Attribute t (const b) (const c)) ->
                          (b -> Maybe d) -> BTemplate t (const d) (const c) -> BTemplate t (const b) (const c)
  maybeOnSpan attrs fn = MaybeNode "span" attrs (\_,y=> fn y)

  export
  listOnDiv : {t:Type} -> List (Attribute t (const b) (const c)) -> (b -> List d) ->
                          BTemplate t (const d) (const c) -> BTemplate t (const b) (const c)
  listOnDiv attrs fn = listCustom "div" attrs (\_,y=> fn y)

  export
  listOnDivIndex : {t:Type} -> List (Attribute t (const b) (const c)) -> (b -> List d) ->
                          BTemplate t (const (Nat, d)) (const c) -> BTemplate t (const b) (const c)
  listOnDivIndex {d} attrs fn = listOnDivIndexD {h=\_=>d} attrs (\_,y=> fn y)

  export
  onclick : {t:Type} -> (b -> c) -> Attribute t (const b) (const c)
  onclick fn = onclickD (\_,y=>fn y)

  export
  onShortPress : {t:Type} -> (b -> c) -> Attribute t (const b) (const c)
  onShortPress fn = EventShortPress (\_,y=>fn y)

  export
  onLongPress : {t:Type} -> (b -> c) -> Attribute t (const b) (const c)
  onLongPress fn = EventLongPress (\_,y=>fn y)

  export
  onclick' : {t:Type} -> c -> Attribute t (const b) (const c)
  onclick' x = onclick (const x)

  export
  onchange : {t:Type} -> (b -> c -> d) -> InputAttribute t (const b) (const d) (const c)
  onchange fn = OnChange (\_,x,y=> fn x y)


  export
  form : {t:Type} -> (b -> c) -> List (Attribute t (const b) (const c)) ->
            List (BTemplate t (const b) (const c)) -> BTemplate t (const b) (const c)
  form fn = FormNode (\_,x=>fn x)

  export
  form' : {t:Type} -> c -> List (Attribute t (const b) (const c)) ->
            List (BTemplate t (const b) (const c)) -> BTemplate t (const b) (const c)
  form' x = FormNode (\_,_=>x)

  export
  foldTemplate : ((x:a) -> s x) -> ((x:a) -> s x -> i x -> (s x, Maybe (r x))) -> ((x:a) -> (y:a) -> s x -> s y) ->
               BTemplate a s i -> List (FoldAttribute a f g s r) -> BTemplate a f g
  foldTemplate = FoldNode

  export
  setVal : {t:Type} -> (b -> Maybe c) -> InputAttribute t (const b) (const d) (const c)
  setVal fn = SetVal (\_,z=> fn z)

  export
  onchange' : {t:Type} -> (c -> d) -> InputAttribute t (const b) (const d) (const c)
  onchange' fn = OnChange (\_,_,x=> fn x)

export
groupAttribute : List (Attribute a f g) -> Attribute a f g
groupAttribute = GroupAttribute

export
textinput : List (InputAttribute a f g (const String)) ->
                BTemplate a f g
textinput = InputNode IText

export
customTextNS : String -> String -> List (Attribute a f g) -> Dyn (DPair a f) String -> BTemplate a f g
customTextNS x = TextNode (Just x)

export
customText : String -> List (Attribute a f g) -> Dyn (DPair a f) String -> BTemplate a f g
customText = TextNode Nothing

export
text : List (Attribute a f g) -> String -> Template a f g
text attrs txt = customText "span" attrs (DynConst txt)

export
textF : {t:Type} -> List (Attribute t (const a) (const b)) -> (a -> String) -> Template t (const a) (const b)
textF attrs txt = customText "span" attrs (DynA $ \(_**x)=> txt x)

export
textD : List (Attribute a f g) -> ((x:a) -> f x -> String) -> Template a f g
textD attrs txt = customText "span" attrs (DynA $ \(x**y)=>txt x y )

export
customNodeWidthPostProc : String -> (DomNode -> GuiCallback a f g -> JS_IO d, d -> JS_IO ()) ->
                            List (Attribute a f g) -> List (BTemplate a f g) -> BTemplate a f g
customNodeWidthPostProc = CustomNode Nothing

export
customNodeWidthPostProcNS : String -> String -> (DomNode -> GuiCallback a f g -> JS_IO d, d -> JS_IO ()) ->
                            List (Attribute a f g) -> List (BTemplate a f g) -> BTemplate a f g
customNodeWidthPostProcNS x = CustomNode (Just x)

export
customNode : String -> List (Attribute a f g) -> List (BTemplate a f g) -> BTemplate a f g
customNode t = CustomNode Nothing t (\_,_=>pure (),\_=>pure ())

export
customNodeNS : String -> String -> List (Attribute a f g) -> List (BTemplate a f g) -> BTemplate a f g
customNodeNS ns t = CustomNode (Just ns) t (\_,_=>pure (),\_=>pure ())

export
customStrAttr : String -> Dyn (DPair a f) String -> BAttribute a f g
customStrAttr = StrAttribute Nothing

export
customStrAttrNS : String -> String -> Dyn (DPair a f) String -> BAttribute a f g
customStrAttrNS x = StrAttribute (Just x)

export
img : List (Attribute a f g) -> String -> Template a f g
img attrs url = customNode "img" (customStrAttr "src" (DynConst url) ::attrs) []

export
imgF : {t:Type} -> List (Attribute t (const a) (const b) ) -> (a->String) -> Template t (const a) (const b)
imgF attrs url = customNode "img" (customStrAttr "src" (DynA $ \(_**x)=> url x) ::attrs) []

export
div : List (Attribute a f g) -> List (BTemplate a f g) -> BTemplate a f g
div = customNode "div"

export
span : List (Attribute a f g) -> List (BTemplate a f g) -> BTemplate a f g
span = customNode "span"

export
button : List (Attribute a f g) -> String -> BTemplate a f g
button attrs x = customNode "button" attrs [text [] x]
