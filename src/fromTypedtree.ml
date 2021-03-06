module F = Typexpr.Raw
open Types

let to_longident = Untypeast.lident_of_path

let map_al f l =
  Sequence.of_list l
  |> Sequence.map f
  |> Sequence.to_array

let rec to_typexpr_raw vars x = match x.desc with
  | Tvar x
  | Tunivar x -> F.var vars x
  | Tarrow (_,arg,ret,_) ->
    let arg = to_typexpr_raw vars arg in
    let ret = to_typexpr_raw vars ret in
    F.arrow arg ret
  | Ttuple tup ->
    let tup = Sequence.of_list tup in
    F.tuple (Sequence.map (to_typexpr_raw vars) tup)
  | Tconstr (p,args,_) ->
    let lid = to_longident p in
    let args = map_al (to_typexpr_raw vars) args in
    F.constr lid args
  | Tlink t
  | Tsubst t
  | Tpoly (t,_) -> to_typexpr_raw vars t

  | Tobject (_,_)
  | Tfield (_,_,_,_)
  | Tnil
  | Tvariant _
  | Tpackage (_,_,_) ->
    F.unknown x.desc

let to_typexpr ?ht x =
  let vars = F.varset () in
  let raw = to_typexpr_raw vars x in
  Typexpr.normalize ?ht vars raw
