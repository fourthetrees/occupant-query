module Sugar exposing (..)

-- Pipe a maybe output into a new function (ltr).
(|~) : Maybe a -> ( a -> b ) -> Maybe b
(|~) x f =
  case x of
    Just a ->
      Just ( f a )
    Nothing ->
      Nothing
infixl 0 |~


-- Pipe a maybe output into a new function (rtl).
(~|) : ( a -> b ) -> Maybe a -> Maybe b
(~|) f x =
  case x of
    Just a ->
      Just ( f a )
    Nothing ->
      Nothing
infixr 0 ~|


-- Pipe a maybe output into a function
-- which also returns a maybe (ltr).
(||~) : Maybe a -> ( a -> Maybe b ) -> Maybe b
(||~) x f =
  case x of
    Just a ->
      f a
    Nothing ->
      Nothing
infixl 0 ||~


-- Pipe a maybe output into a function
-- which also returns a maybe (rtl).
(~||) : ( a -> Maybe b ) -> Maybe a -> Maybe b
(~||) f x =
  case x of
    Just a ->
      f a
    Nothing ->
      Nothing
infixr 0 ~||


-- Pipe a result output into a new function (ltr).
(|!) : Result e a -> ( a -> b ) -> Result e b
(|!) x f =
  case x of
    Ok a ->
       Ok ( f a )
    Err e ->
      Err e
infixl 0 |!


-- Pipe a result output into a new function (rtl).
(!|) : ( a -> b ) -> Result e a -> Result e b
(!|) f x =
  case x of
    Ok a ->
       Ok ( f a )
    Err e ->
      Err e
infixr 0 !|



-- Pipe a result output into a function
-- which also returns a maybe (ltr).
(||!) : Result e a -> ( a -> Result e b ) -> Result e b
(||!) x f =
  case x of
    Ok a ->
       f a
    Err e ->
      Err e
infixl 0 ||!


-- Pipe a result output into a function
-- which also returns a maybe (rtl).
(!||) : ( a -> Result e b ) -> Result e a -> Result e b
(!||) f x =
  case x of
    Ok a ->
       f a
    Err e ->
      Err e
infixr 0 !||


-- Unwrap maybe or supply default value (ltr)
(/~) : Maybe a -> a -> a
(/~) m d =
  case m of
    Just v ->
      v
    Nothing ->
      d
infixl 0 /~

-- Unwrap maybe or supply default value  (rtl)
(~/) : a -> Maybe a -> a
(~/) d m =
  case m of
    Just v ->
      v
    Nothing ->
      d
infixr 0 ~/


-- Unwrap Ok or supply default (ltr).
(/!) : Result e a -> a -> a
(/!) r d =
  case r of
    Ok v ->
       v
    Err _ ->
      d
infixl 0 /!


-- Unwrap Ok or supply default (rtl).
(!/) : a -> Result e a -> a
(!/) d r =
  case r of
    Ok v ->
       v
    Err _ ->
      d
infixl 0 !/
