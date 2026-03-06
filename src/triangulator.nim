#   MIT License - Copyright (c) 2025 Eray Zesen
#   Github: https://github.com/erayzesen/kirpi
#   License information: https://github.com/erayzesen/kirpi/blob/master/LICENSE

type

  Triangle* = object
    a*, b*, c*: tuple[x,y:float]

# ---------------- Vector operations ----------------
proc `-`(a,b:tuple[x,y:float]): tuple[x,y:float] = (x:a.x-b.x, y:a.y-b.y)
proc cross(a,b:tuple[x,y:float]): float64 = a.x*b.y - a.y*b.x

# ---------------- Reflex / ear tests ----------------
proc isReflex(prev,curr,next:tuple[x,y:float]): bool =
  cross(curr - prev, next - curr) < 0.0

proc pointInTriangle(p,a,b,c:tuple[x,y:float]): bool =
  # half-space method
  let ab = b - a
  let bc = c - b
  let ca = a - c
  let ap = p - a
  let bp = p - b
  let cp = p - c
  let c1 = cross(ab, ap)
  let c2 = cross(bc, bp)
  let c3 = cross(ca, cp)
  (c1 >= 0 and c2 >= 0 and c3 >= 0) or (c1 <= 0 and c2 <= 0 and c3 <= 0)

# ---------------- Triangulation ----------------
proc triangulate*(poly: seq[tuple[x,y:float]]): seq[ tuple[x,y:float] ] =
  let n = poly.len
  if n < 3: return @[]
  if n == 3: return @[ (x:poly[0].x, y: poly[0].y), (x:poly[1].x, y: poly[1].y) ,(x:poly[2].x, y:poly[2].y) ]

  var idx = newSeq[int](n)
  for i in 0..<n: idx[i] = i

  var reflex = newSeq[bool](n)
  proc updateReflex(i:int) =
    let L = idx[(i-1+idx.len) mod idx.len]
    let C = idx[i]
    let R = idx[(i+1) mod idx.len]
    reflex[C] = isReflex(poly[L], poly[C], poly[R])

  for i in 0..<idx.len: updateReflex(i)

  var res: seq[ tuple[x,y:float]] = @[]
  res.setLen(0)
  var iterations = 0
  let maxIter = n*5

  while idx.len > 3:
    iterations.inc
    if iterations > maxIter: break

    var earFound = false

    for i in 0..<idx.len:
      let pi = idx[(i-1+idx.len) mod idx.len]
      let ci = idx[i]
      let ni = idx[(i+1) mod idx.len]

      if reflex[ci]: continue

      let A = poly[pi]
      let B = poly[ci]
      let C = poly[ni]

      var bad = false
      for v in idx:
        if v==pi or v==ci or v==ni: continue
        if reflex[v] and pointInTriangle(poly[v],A,B,C):
          bad = true
          break
      if bad: continue

      
      res.add((x:A.x,y:A.y) )
      res.add( (x:B.x,y:B.y) )
      res.add( (x:C.x,y:C.y) )
      
      idx.delete(i)

      # update reflex for neighbors
      if idx.len > 2:
        updateReflex((i-1+idx.len) mod idx.len)
        updateReflex(i mod idx.len)

      earFound = true
      break

    if not earFound:
      # fallback for degenerate or self-intersecting polygons
      let a = idx[0]
      let b = idx[1]
      let c = idx[2]

      res.add( (x:poly[a].x,y:poly[a].y) )
      res.add( (x:poly[b].x,y:poly[b].y) )
      res.add( (x:poly[c].x,y:poly[c].y) )
      
      
      idx.delete(1)

  if idx.len == 3:
    res.add( (x:poly[idx[0]].x, y:poly[idx[0]].y) )
    res.add( (x:poly[idx[1]].x, y:poly[idx[1]].y) )
    res.add( (x:poly[idx[2]].x, y:poly[idx[2]].y) )
    

  return res
