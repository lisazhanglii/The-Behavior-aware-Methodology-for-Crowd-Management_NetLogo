extensions [table]
breed [ persons person ] ; agents that need to exit

globals[
  key-timestep
  key-timestep-list
  key-timestep-dvalue
  key-timestep-dvalue-mean
  peek-mean-mean
  peek-mean-mean-mean
  ;used to delay the tick
  tick-accum
  start-point
  tleft tright ; total number of persons exitting from left and right
  speed using-left using-right last-left last-right max-agents-in-surge-rational max-agents-in-surge-emotional max-surge-value
  max-density mean-density
  open-index
  surge-number
  panic-number
  surge-number-single
  panic-number-single
  surge-left
  surge-right
  exceeding-patch-percentage
  a
  this-round
  dangerlist
  accu-step
  rational
  frequency
  allow-one-change
]

patches-own [ density-patch decision area-density path obstacle stage bar restroom exit area x-big y-big density structure-type walkable? exit-id doms steps-to-exits patch-value-left patch-value-right patch-value-bar patch-value-restroom; variables representing environment
  updated? initial-target-exit dom spread-update-left? spread-update-right? ; helping environment varaibles
]

persons-own [comfort-zone stop-index hesitation-time hesitation-bar person-speed bar-index density-person curr-dir curr-exit state in-surge-for moving-for waiting-for rational? has-changed?]


to setup
  random-seed 12345
  create-env
  setup-areas

  ; creates environment with 2 exits (left and right), environment type: can be 1, 2 or 3; 1 is symmetric, 2 is asymmetric, and 3 is (one exit) invisible, and floor field
  setup-agents

  ;setup-topo
  ; sets up persons, based on
  ; 1: number of persons
  ; 2: rational persons %

  InitializeGlobals
  ; initialies global parameters
  ;set density-1 [count turtles-here] of patches with [ area = 1]


end

;;;;;;;;;;;;;;;;;;;; INITIALIZE GLOBALS ;;;;;;;;;;;;;;;;;;;;;

to InitializeGlobals
  set speed 1
  set using-left 0
  set using-right 0
  set last-left 0
  set last-right 0
  set max-agents-in-surge-rational 0
  set max-agents-in-surge-emotional 0
  set max-surge-value 0
  set start-point 0
  set tick-accum 0
  set allow-one-change false
  set surge-left false
  set surge-right false
  set a ""
  set open-index 4
  set exceeding-patch-percentage 0
  set surge-number 0
  set panic-number 0
  set dangerlist []
  let number 1
  set rational 0
  set accu-step table:make
  while [number <= 500]
  [
    table:put accu-step number 0
    set number (number + 1)
  ]
  set key-timestep 0
  set key-timestep-list []
  set key-timestep-dvalue 0
  set key-timestep-dvalue-mean 0
  set frequency 0
  set peek-mean-mean 0
  set peek-mean-mean-mean 0
  set surge-number-single 0
  set panic-number-single 0

end

to go
  let change 0
  let change-2 0
  set max-density 0
  let used table:make
  set peek-mean-mean ((panic-number + surge-number) / 2)
  set peek-mean-mean-mean  peek-mean-mean / (ticks + 1)
  let number2 1
  while [number2 <= 500]
  [
    table:put used number2 0
    set number2 (number2 + 1)
  ]
  set surge-number-single count persons with [state = "surge"]
  set panic-number-single count persons with [state = "panic"]
  set surge-number surge-number + count persons with [state = "surge"]
  set panic-number panic-number + count persons with [state = "panic"]
  let exceeding-patch-percentage-1 count patches with [density-patch > 0.9 ]
  set exceeding-patch-percentage exceeding-patch-percentage-1 / count patches
  ask patches[
  let area-now area
  set density-patch mean [count turtles-here] of patches with [area = area-now]
  ]
  ask persons
  [
  let area-now [area] of patch-here
  ; calculate the density of the patch where the person is on
  set density-person mean [count turtles-here] of patches with [area = area-now]
  if (density-person > 0.7 )and ((member? area-now dangerlist) = false) and (state = "surge" or state = "panic")[ set dangerlist lput area-now dangerlist]
  if density-person <= 0.7 and (member? area-now dangerlist) = true [ set dangerlist remove area-now dangerlist]
 ; if max-density < density-person [set max-density density-person]

  ifelse bar-index > 0 [str6 ifelse bar-index > bar-restoom-time [set bar-index 0][set bar-index bar-index + 1]]; when people will go bar
    [
      ifelse ticks mod bar-restroom-frequency = 1 [let r random 10 if r < 4 [str6 set bar-index bar-index + 1]];this is to choose some people to go bar
      [
        if table:get used area-now = 0
        [
          table:put used area-now 1
          ifelse (member? area-now dangerlist) = false
          [
             table:put accu-step area-now 0
          ]
          [
            table:put accu-step area-now (table:get accu-step area-now) + 1
            let b [decision] of patch-here
            if (table:get accu-step area-now > switch-index) and (a != b) and ((member? (area-now + 1) dangerlist) = true) and ((member? (area-now + 10) dangerlist) =  true) and  ((member? (area-now + 11) dangerlist) =  true)
            [
              set change 1
              table:put accu-step area-now 0
              set key-timestep-dvalue (ticks -  key-timestep)
              set key-timestep ticks
              set key-timestep-list lput key-timestep-dvalue key-timestep-list
              set key-timestep-dvalue-mean mean key-timestep-list
              set frequency 1 / key-timestep-dvalue-mean
              set a b
            ]
          ]
        ]
        ifelse change = 1 [set hesitation-time hesitation-time + 1][if hesitation-time != 0 [set hesitation-time hesitation-time + 1]]
        if (open-index = 4) and (hesitation-time >= hesitation-bar)[str4 set hesitation-time 0]
        if (open-index = 5) and (hesitation-time >= hesitation-bar)[str5 set hesitation-time 0]
        if (open-index = 4) and (hesitation-time < hesitation-bar)[str5]
        if (open-index = 5) and (hesitation-time < hesitation-bar)[str4]
      ]
    ]

  set curr-dir get-direction-to-dest curr-exit
  set heading curr-dir
      move-now
    ]
  if change = 1
  [
    ifelse open-index = 4 [set open-index 5 set change 0 ][set open-index 4 set change 0]
  ]
  set-globals
  tick
end

to setup-areas
  ask patches [set x-big floor ((  pxcor  ) / 5)  set y-big floor ((  pycor  ) / 5)]
  ask patches [set area 10 * y-big + x-big + 1]
end

to-report str1
  let exitsel ""
  let dist 9999
  let patch-ste [steps-to-exits] of patch-here

  let allf table:keys patch-ste
  foreach allf[ [z] ->
    let d table:get patch-ste z
    if (d < dist) [
      set dist d
      set exitsel z
    ]
  ]

  report exitsel
end

to str2
  let cnt count turtles-on neighbors
  if (cnt > 0) [
    let ag one-of turtles-on neighbors
    let exit_ag [curr-exit] of ag
    let exit_a curr-exit
    let payoff -1
    let prob -1
    let r random 10

    if (not rational?) [
      ifelse (exit_ag = exit_a) [
        ;set prob (1 / (9 + (0.644 ^ -0))) ; no change CHANGE WITH with prob 0
        ;set prob int (prob * 10)
        ;if (prob = r) [set curr-exit  exit_ag]
        ]
      [
        if (in-surge-for > 0) [
          set prob (1 / (9 + (0.644 ^ -0))) ; ; no change CHANGE WITH with prob 0.1
          set prob int (prob * 10)
          if (prob = r) [set curr-exit  exit_ag]
          ]

      ]
    ]

    if (rational? and in-surge-for <= 0) [
      ifelse (exit_ag = exit_a) [
        if (not has-changed?)[
          set prob (1 / (9 + (0.644 ^ -0))) ; ; no change CHANGE WITH with prob 0.1
          ;set prob 1 - (1 / (1 + 0.644 ^ -5)) ; definately change with prob 0.9]
          set prob int (prob * 10)
          if (prob = r) [ifelse (curr-exit = "left") [set curr-exit "right" if (allow-one-change) [set has-changed? true]][set curr-exit "left" if (allow-one-change) [set has-changed? true]]]

          ]
        ]
      [
        if (not has-changed?)[
          set prob 1 - (1 / (1 + 0.644 ^ -5)) ; definately change with prob 0.9]
          set prob int (prob * 10)
          if (prob = r) [ifelse (curr-exit = "left") [set curr-exit "right" if (allow-one-change) [set has-changed? true]][set curr-exit "left" if (allow-one-change) [set has-changed? true]]]

          ]

      ]
    ]

    if (rational? and in-surge-for > 0 and not has-changed?) [
      ifelse (exit_ag = exit_a) [

          ifelse (curr-exit = "left") [set curr-exit "right" if (allow-one-change) [set has-changed? true]][set curr-exit "left" if (allow-one-change) [set has-changed? true]]


        ]
      [
        ;set prob (1 / (9 + (0.644 ^ -0))) ; no change CHANGE with prob 0

      ]
    ]

    if (rational? and in-surge-for > 0 and has-changed?) [
      if (exit_ag = exit_a) [

          ifelse (curr-exit = "left") [set curr-exit "right" if (allow-one-change) [set has-changed? true]][set curr-exit "left" if (allow-one-change) [set has-changed? true]]


        ]

    ]

  ]
end

to str3

  let cnt count turtles-on neighbors
  if (cnt > 0) [
    let ag one-of turtles-on neighbors
    let exit_ag [curr-exit] of ag
    let exit_a curr-exit
    let payoff -1
    let prob -1
    let r random-float 1

    let pvl patch-value-left ;of patch-here
    let pvr patch-value-right ;of patch-here
    let exit-value ""


    if (pvl > pvr) [set exit-value  "left"]
    if (pvr > pvl) [set exit-value  "right"]



    if (rational? and in-surge-for <= 0) [
      ifelse (exit_ag = exit_a) [
        ifelse(exit_a = exit-value) []
        [
          set prob (1 / (1 + 0.644 ^ 2.5))
          if (prob >= r) [ifelse (curr-exit = "left") [set curr-exit "right"][set curr-exit "left"]]       ;do with prob 0.75
        ]
      ]
      [
        ifelse(exit_a = exit-value) []
        [
          set prob (1 / (1 + 0.644 ^ -2.5))
          if (prob >= r) [ifelse (curr-exit = "left") [set curr-exit "right"][set curr-exit "left"]]       ;do with prob 0.25
        ]
      ]
    ]

    if (rational? and in-surge-for > 0) [
    ifelse (exit_ag = exit_a) [
      ifelse(exit_a = exit-value) [
        set prob (1 / (1 + 0.644 ^ -2.5))
        if (prob >= r) [ifelse (curr-exit = "left") [set curr-exit "right"][set curr-exit "left"]]       ;do with prob 0.25
      ]
      [
        ifelse (curr-exit = "left") [set curr-exit "right"][set curr-exit "left"]
      ]
    ]

    [
      ifelse(exit_a = exit-value) []
        [
          set prob (1 / (1 + 0.644 ^ 2.5))
          if (prob >= r) [ifelse (curr-exit = "left") [set curr-exit "right"][set curr-exit "left"]]       ;do with prob 0.75
        ]
    ]

    ]
  ]
end

to str4
  let cnt count turtles-on neighbors
  if (cnt > 0) [
    let ag one-of turtles-on neighbors
    let exit_ag [curr-exit] of ag
    let exit_a curr-exit
    let payoff -1
    let prob -1
    let r random-float 1

    let pvl patch-value-left ;of patch-here
    let pvr patch-value-right ;of patch-here
    let exit-value ""
  set exit-value  "left"
    set curr-exit "left"
  ]

end

to str5
  let cnt count turtles-on neighbors
  if (cnt > 0) [
    let ag one-of turtles-on neighbors
    let exit_ag [curr-exit] of ag
    let exit_a curr-exit
    let payoff -1
    let prob -1
    let r random-float 1

    let pvl patch-value-left ;of patch-here
    let pvr patch-value-right ;of patch-here
    let exit-value ""
  set exit-value  "right"
    set curr-exit "right"]

end

to str6
  let cnt count turtles-on neighbors
  if (cnt > 0) [
    let ag one-of turtles-on neighbors
    let exit_ag [curr-exit] of ag
    let exit_a curr-exit
    let payoff -1
    let prob -1
    let r random-float 1
    let bar-random random 2
    let pvl patch-value-left ;of patch-here
    let pvr patch-value-right ;of patch-here
    let exit-value ""
    ifelse bar-random = 0 [set exit-value  "bar" set curr-exit "bar"][set exit-value "restroom" set curr-exit "restroom"]
]

end



to-report get-direction-to-dest [dest]
  let patch-dom [doms] of patch-here
  report table:get patch-dom dest
end

to move-now
  if (state = "start" or state = "walk")[set color 9.9 - 2 move-forward]
  if (state = "wait") [set color 114 move-forward]
  if (state = "surge") [set color red move-forward]
  if (state = "panic") [set color pink move-forward]




  if (state = "end")
  [
      ifelse (curr-exit = "left") [announce "left" set using-left using-left + 1 set last-left ticks] [announce "right" set using-right using-right + 1 set last-right ticks]  die


  ]
end

to move-forward

  let x table:get steps-to-exits "left"
  let y table:get steps-to-exits "right"
  let z table:get steps-to-exits "bar"
  let k table:get steps-to-exits "restroom"
  let patch-now patch-here
  let sl [table:get steps-to-exits "left"] of patch-now
  let sr [table:get steps-to-exits "right"] of patch-now
  let sb [table:get steps-to-exits "bar"] of patch-now
  let sr2 [table:get steps-to-exits "restroom"] of patch-now
  ifelse (curr-exit = "right" and (z <= 3 or k <= 3)) or (curr-exit = "left" and (z <= 3 or k <= 3))[fd person-speed set in-surge-for 0 set waiting-for 0 set moving-for moving-for + 1 set state "walk"]
 [
    ifelse sl <= 0 [rt 90 fd person-speed set in-surge-for 0  set waiting-for 0 set moving-for moving-for + 1 set state "walk"][
      ifelse sr <= 0 [lt 0 fd person-speed set in-surge-for 0  set waiting-for 0 set moving-for moving-for + 1 set state "walk"][
        ifelse sb <= 0 [rt 180 fd person-speed set in-surge-for 0  set waiting-for 0 set moving-for moving-for + 1 set state "walk"][
    if x <= comfort-zone or y <= comfort-zone or z <= 1 or k <= 1[if (x <= comfort-zone and curr-exit = "left") or (y <= comfort-zone and curr-exit = "right") or (z <= 1 and curr-exit = "bar") or (k <= 1 and curr-exit = "restroom") [stop]]
  ifelse not any? other turtles-on patch-ahead person-speed [fd person-speed  set in-surge-for 0  set waiting-for 0 set moving-for moving-for + 1 set state "walk"]
    [

      ifelse scan-neighbor-right 45 [rt 45 fd person-speed set in-surge-for 0  set waiting-for 0 set moving-for moving-for + 1 set state "walk"]
      [
        ifelse scan-neighbor-left 45 [lt 45 fd person-speed set in-surge-for 0  set waiting-for 0 set moving-for moving-for + 1 set state "walk"]
        [
          ifelse scan-neighbor-right 90 [rt 90 fd person-speed set in-surge-for 0  set waiting-for 0 set moving-for moving-for + 1 set state "walk"]
          [
            ifelse scan-neighbor-left 90 [lt 90 fd person-speed set in-surge-for 0  set waiting-for 0 set moving-for moving-for + 1 set state "walk"]
            [
              ifelse scan-neighbor-right 135 [rt 135 fd person-speed set in-surge-for 0  set waiting-for 0 set moving-for moving-for + 1 set state "walk"]
              [
                ifelse scan-neighbor-left 135 [lt 135 fd person-speed set in-surge-for 0  set waiting-for 0 set moving-for moving-for + 1 set state "walk"]
                [
                  set waiting-for waiting-for + 1 set moving-for 0 set state "wait"
                  if ((waiting-for > waiting-threshold-surge) and (curr-exit = "left" or curr-exit = "right")) [set state "surge" set in-surge-for in-surge-for + 1 if (max-surge-value < in-surge-for) [set max-surge-value in-surge-for] set moving-for 0]
                   if ((waiting-for > waiting-threshold-panic) and (curr-exit = "bar" or curr-exit = "restroom")) [set state "panic" set in-surge-for in-surge-for + 1 if (max-surge-value < in-surge-for) [set max-surge-value in-surge-for] set moving-for 0]
                ]
              ]
            ]
          ]
        ]
      ]
  ]]]]]

   ; if [structure-type] of patch-here = "exit" [set state  "end"]
end

to-report scan-neighbor-right [angle]
  let return? false
  let praa patch-right-and-ahead  angle person-speed
  ;if ([structure-type] of praa = "wall") [report return?]
  ;let c count other turtles-on praa
  ;ifelse praa = nobody [][if (c <= 3) [set return? true]]
  ifelse praa = nobody [][if not any? other turtles-on praa [set return? true]]
  report return?
end

to-report scan-neighbor-left [angle]
  let return? false
  let plaa patch-left-and-ahead  angle person-speed
  ;if ([structure-type] of plaa = "wall") [report return?]
  ifelse plaa = nobody [][if not any? other turtles-on plaa [set return? true]]
  report return?
end

to announce [ex]
  let ph patch-here
  ask ph [
    ask neighbors [ifelse ex = "left" [set patch-value-left patch-value-left + 1] [set patch-value-right patch-value-right + 1]]
  ]
end

to set-globals
  let c count persons with [in-surge-for > 0 and rational?]
  if (c > max-agents-in-surge-rational) [set max-agents-in-surge-rational c]
  let d count persons with [in-surge-for > 0 and not rational?]
  if (d > max-agents-in-surge-emotional) [set max-agents-in-surge-emotional d]
end

to spread
  ask patches [set spread-update-left? false set spread-update-right? false]
  ask patches [
    if (patch-value-left > 0) [
      let pvl patch-value-left
      ask neighbors [
        if not spread-update-left? [
          if (patch-value-left <  pvl) [set patch-value-left (pvl - (pvl / 10)) set spread-update-left? true]
         ; set pcolor orange + patch-value-right
        ]
      ]
    ]

    if (patch-value-right > 0) [
      let pvr patch-value-right
      ask neighbors [
        if not spread-update-right? [
          if (patch-value-left <  pvr) [set patch-value-right  (pvr - (pvr / 10)) set spread-update-right? true]
         ; set pcolor yellow + patch-value-right
        ]
      ]
    ]

    if (patch-value-left = 0 and patch-value-right = 0) [set pcolor white]

  ]
end

to decay
  ask patches [
    let dl patch-value-left / 10
    let dr patch-value-right / 10
    ifelse (patch-value-left > 0.1) [set patch-value-left patch-value-left - dl] [set patch-value-left 0]
    ifelse (patch-value-right > 0.1) [set patch-value-right patch-value-right - dr] [set patch-value-right 0]
  ]
end


;;;;;;;;;;;;;;;;;;;; PERSONS SETUP ;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup-agents
  clear-turtles
  reset-ticks
  create-persons num-agents [
    move-to one-of patches with [structure-type = "floor" and (not any? other turtles-here) and (table:get steps-to-exits "left" > 2)  and (table:get steps-to-exits "right" > 2) and (table:get steps-to-exits "bar" > 2) and (table:get steps-to-exits "restroom" > 2)]
    set color 9.9
    set state "start"
    set in-surge-for 0
    set moving-for 0
    set waiting-for 0
    set rational? false
    set has-changed? false
    set curr-exit str1
    set bar-index 0
    set person-speed 1 + random 1
    set hesitation-bar 1 + random 1
    set hesitation-time 0 + random 20
    set stop-index 0
    set comfort-zone 1 + random 10
  ]
  setrational
end

to setrational
  let r  rational *  num-agents / 100
  let i 0
  while [i < r] [
    ask one-of turtles with [rational? = false] [set rational? true set shape "circle"]
    set i i + 1
    ]
end

to-report set-a-random-exit
  let r random 2
  ifelse (r = 0) [report "left"] [report "right"]
end

;;;;;;;;;;;;;;;;;;;;;; ENVIRONMENT SETUP ;;;;;;;;;;;;;;;;;;;;;;;;;;;

to create-env
  clear-all

 ask patches [set pcolor gray set walkable? true set doms table:make set steps-to-exits table:make set updated? false set structure-type "floor" set patch-value-left 0.0 set patch-value-right 0.0 set patch-value-bar 0.0 set patch-value-restroom 0.0]
  ;setup-exterior-walls
  setup-exits
  set-doms-ste-default
  setup-potential-map
end

to setup-exterior-walls
  let walls patches with [((pxcor >= min-pxcor and pxcor <= max-pxcor) and (pycor = max-pycor))]
  ask walls [set structure-type "wall" set walkable? false set pcolor black]
  set walls patches with [((pxcor >= min-pxcor and pxcor <= max-pxcor) and (pycor = min-pycor))]
  ask walls [set structure-type "wall" set walkable? false set pcolor black]
  set walls patches with [((pycor >= min-pycor and pycor <= max-pycor) and (pxcor = max-pxcor))]
  ask walls [set structure-type "wall" set walkable? false set pcolor black]
  set walls patches with [((pycor >= min-pycor and pycor <= max-pycor) and (pxcor = min-pxcor))]
  ask walls [set structure-type "wall" set walkable? false set pcolor black]
end

to setup-exits
  if (env-type = 1) [setup-exit 0 26 0 3 "left"  setup-exit 50 26 0 3 "right"]
  if (env-type = 2) [setup-exit 0 50 0 3 "left"  setup-exit 50 3 0 3 "right" setup-exit 20 50 0 0 "bar" setup-exit 20 0 0 0 "restroom"]
  if (env-type = 3) [setup-exit 0 26 0 3 "left"  setup-exit 50 3 0 3 "right" setup-obstacles]


end

to setup-obstacles
  let obstacles patches with [(pxcor >= 20 and pycor = 50) and (pxcor <= 22 and pycor = 50)]
  ask obstacles [set walkable? false set structure-type "obstacle" set pcolor gray]
end

to setup-exit [startx starty len wid id]
  let exits patches with [(pxcor >= startx and pycor <= starty) and (pxcor <= startx + len and pycor >= starty - wid)]
  ask exits [set walkable? false set structure-type "exit" set exit-id id set pcolor red]

end

to setup-potential-map
  ask patches with [structure-type = "exit"][
    let gx pxcor
    let gy pycor
    let te exit-id
   ;   let neigh-patches2 neighbors with [structure-type = "exit"]
  ;ask neigh-patches2 [set walkable? false]
    let neigh-patches neighbors with [structure-type != "exit" and walkable?]
    ask neigh-patches[
      let o towardsxy gx gy
      let d table:get doms te
      if (d = -1) [table:put doms te o set initial-target-exit te table:put steps-to-exits te 0 set dom o set updated? true]
      ]
  ]

   while [count patches with [structure-type = "floor" and updated? = false] > 0][update-patchbar]
  ask patches with [structure-type = "floor" and initial-target-exit != "restroom"] [set updated? false]
  while [count patches with [structure-type = "floor" and updated? = false] > 0][update-patchrestroom]
   ask patches with [structure-type = "floor" and initial-target-exit != "left"] [set updated? false]
  while [count patches with [structure-type = "floor" and updated? = false] > 0][update-patchleft]
    ask patches with [structure-type = "floor" and initial-target-exit != "right"] [set updated? false]
    while [count patches with [structure-type = "floor" and updated? = false] > 0][update-patchright]

    ask patches with [structure-type = "floor"] [set pcolor white]
    ask patches with [structure-type = "floor"] [ifelse table:get steps-to-exits "left" > table:get steps-to-exits "right" [set decision "right" set pcolor 84][set decision "left" set pcolor 102]]
end


to update-patchleft
  ask patches with [structure-type = "floor" and table:get doms "left" != -1][
      let gx pxcor
      let gy pycor

      let x table:get steps-to-exits "left"
      let neigh-patches neighbors with [structure-type != "exit" and walkable? and table:get doms "left" = -1]
      ask neigh-patches[
        let o towardsxy gx gy
           if (table:get doms "left" = -1) [
             table:put doms "left" o

             table:put steps-to-exits "left" x + 1
             ]
           set pcolor gray
           set updated? true
      ]
  ]
end

to update-patchright
  ask patches with [structure-type = "floor" and table:get doms "right" != -1][
      let gx pxcor
      let gy pycor

      let x table:get steps-to-exits "right"
      let neigh-patches neighbors with [structure-type != "exit" and walkable? and table:get doms "right" = -1]
      ask neigh-patches[
        let o towardsxy gx gy
           if (table:get doms "right" = -1) [
             table:put doms "right" o
             table:put steps-to-exits "right" x + 1
             ]
           set pcolor black
           set updated? true
      ]
  ]
end

to update-patchbar
  ask patches with [structure-type = "floor" and table:get doms "bar" != -1][
      let gx pxcor
      let gy pycor

      let x table:get steps-to-exits "bar"
      let neigh-patches neighbors with [structure-type != "exit" and walkable? and table:get doms "bar" = -1]
      ask neigh-patches[
        let o towardsxy gx gy
           if (table:get doms "bar" = -1) [
             table:put doms "bar" o
             table:put steps-to-exits "bar" x + 1
             ]
           set pcolor black
           set updated? true
      ]
  ]
end
to update-patchrestroom
  ask patches with [structure-type = "floor" and table:get doms "restroom" != -1][
      let gx pxcor
      let gy pycor

      let x table:get steps-to-exits "restroom"
      let neigh-patches neighbors with [structure-type != "exit" and walkable? and table:get doms "restroom" = -1]
      ask neigh-patches[
        let o towardsxy gx gy
           if (table:get doms "restroom" = -1) [
             table:put doms "restroom" o
             table:put steps-to-exits "restroom" x + 1
             ]
           set pcolor black
           set updated? true
      ]
  ]
end

to set-doms-ste-default
  ask patches[

    table:put doms "left" -1
    table:put doms "right" -1
    table:put doms "bar" -1
    table:put doms "restroom" -1

    table:put steps-to-exits "left" 0
    table:put steps-to-exits "right" 0
    table:put steps-to-exits "bar" 0
    table:put steps-to-exits "restroom" 0


    ]
end