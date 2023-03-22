module Dom_html = Js_of_ocaml.Dom_html
module Dom = Js_of_ocaml.Dom
module Js = Js_of_ocaml.Js
module Firebug = Js_of_ocaml.Firebug

(* module WebSockets = Js_of_ocaml.WebSockets *)
module WebSocket = Brr_io.Websocket
module Ev = Brr.Ev

let regexp_left_paren = Re.Str.regexp_string "("
let regexp_right_paren = Re.Str.regexp_string ")"
let encoded_left_paren = "%28"
let encoded_right_paren = "%29"

let encode_parens s : Jstr.t =
  let s' = Jstr.to_string s in
  let s_lp_encoded =
    Re.Str.global_replace regexp_left_paren encoded_left_paren s'
  in
  let s_rp_encoded =
    Re.Str.global_replace regexp_right_paren encoded_right_paren s_lp_encoded
  in
  Jstr.of_string s_rp_encoded

(* let js_str = Js.string *)
let document = Dom_html.document

let inject_log_lines data =
  let new_div = Dom_html.createDiv document in
  new_div##.innerHTML := data;

  let scroller = Dom_html.getElementById "logs-pre" in
  Dom.appendChild scroller new_div

let ws_path window =
  let location = Brr.Window.location window in
  let pathname = Brr.Uri.path location in
  let port = Brr.Uri.port location in
  let hostname = Brr.Uri.host location in
  match port with
  | None ->
      Jstr.concat ~sep:(Jstr.of_string "/")
        [
          Jstr.of_string "ws:/";
          hostname;
          encode_parens @@ Jstr.append (Jstr.of_string "ws") pathname;
        ]
  | Some port ->
      Jstr.concat ~sep:(Jstr.of_string "/")
        [
          Jstr.of_string "ws:/";
          Jstr.concat ~sep:(Jstr.of_string ":") [ hostname; Jstr.of_int port ];
          encode_parens @@ Jstr.append (Jstr.of_string "ws") pathname;
        ]

(* Would like to do below but it looks like parens are not being percent encoded - will file an issue with Brr
   Brr.Uri.with_uri ~scheme:(Jstr.of_string "ws")
   ~path:(encode_parens @@ Jstr.append (Jstr.of_string "ws") pathname)
   location *)

let go _ =
  let line_number = ref 0 in
  let window = Brr.G.window in
  (* this will throw an exception if the encoding fails *)
  let ws_path = ws_path window in
  let socket = WebSocket.create ws_path in
  let target = WebSocket.as_target socket in
  let result =
    Ev.listen Brr_io.Message.Ev.message
      (fun e ->
        let data = Brr_io.Message.Ev.data (Ev.as_type e) in
        inject_log_lines
        @@ Js.string
        @@ Process_chunk.go line_number (Js.to_string data))
      target
  in
  ignore result;
  Js._true

let _ = Dom_html.window##.onload := Dom_html.handler go
