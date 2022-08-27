module Client = Ocaml_ci_api.Client
module Run_time = Client_utilities.Run_time

open Tyxml.Html

  let to_iso8601 (tt : float) =
    let ts = Timedesc.of_timestamp_float_s tt in
    Timedesc.to_iso8601 @@ Option.get ts

let ul_timestamps ~queued_at ~started_at ~finished_at =
  let queued_at =
    Option.fold ~none:"-" ~some:to_iso8601 queued_at
  in
  let started_at =
    Option.fold ~none:"-" ~some:to_iso8601 started_at
  in
  let finished_at =
    Option.fold ~none:"-" ~some:to_iso8601 finished_at
  in
  ul
    [
      li [ txt @@ Fmt.str "Queued at: %s" queued_at ];
      li [ txt @@ Fmt.str "Started at: %s" started_at ];
      li [ txt @@ Fmt.str "Finished at: %s" finished_at ];
    ]

let of_step step_info =
  match step_info with
  | None -> div [ span [ txt @@ Fmt.str "-" ] ]
  | Some step_info ->
    let queued_at = step_info.Client.queued_at in
    let started_at = step_info.Client.started_at in
    let finished_at = step_info.Client.finished_at in
    ul_timestamps ~queued_at ~started_at ~finished_at

let show (ts : Run_time.timestamps option) =
  match ts with
  | None -> div [ span [ txt @@ Fmt.str "-" ] ]
  | Some t -> (match t with
    | Queued v -> ul_timestamps ~queued_at:(Some v) ~started_at:None ~finished_at:None
    | Running v -> ul_timestamps ~queued_at:(Some v.ready) ~started_at:(Some v.started) ~finished_at:None
    | Finished v -> ul_timestamps ~queued_at:(Some v.ready) ~started_at:v.started ~finished_at:(Some v.finished))