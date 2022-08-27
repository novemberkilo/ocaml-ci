module Client = Ocaml_ci_api.Client
module Run_time = Client_utilities.Run_time
val to_iso8601 : float -> string
val ul_timestamps :
  queued_at:float option ->
  started_at:float option ->
  finished_at:float option -> [> Html_types.ul ] Tyxml_html.elt
val of_step : Client.job_info option -> [> `Div | `Ul ] Tyxml_html.elt
val show : Run_time.timestamps option -> [> `Div | `Ul ] Tyxml_html.elt