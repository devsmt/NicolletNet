type date = { y : int ; m : int ; d : int }

let date_of_string str = 
  Scanf.sscanf str "%d-%d-%d" (fun y m d -> { y ; m ; d }) 

let explode str sep = 
  BatList.filter_map begin fun str -> 
    let str = BatString.strip str in 
    if str = "" then None else Some str
  end (BatString.nsplit str sep) 

type t = {
  title   : string option ; 
  date    : date option ;
  tags    : string list ; 
  draft   : bool ;
  content : string ; 
}

let title str t = 
  { t with title = Some (BatString.strip str) }

let date str t = 
  { t with date = Some (date_of_string str) }

let tags str t = 
  { t with tags = explode str " " }

let draft _ t = 
  { t with draft = true }

let load str = 
  let rec read str = 
    if String.length str = 0 || str.[0] <> '@' then 
      { title   = None ;
	date    = None ;
	tags    = [] ;
	draft   = false ;
	content = str }
    else 
      let line, rest = BatString.split str "\n" in
      let command, args = try BatString.split line " " with Not_found -> line, "" in
      let action = match command with 
	| "@title" -> title
	| "@date"  -> date
	| "@tags"  -> tags
	| "@draft" -> draft
	| _        -> (fun _ t -> t) 
      in
      action args (read rest) 
  in
  read str
