const exploredRoomsKey = 'zork:explored-room-ids';

const loadExploredRooms = () => {
  try {
    const parsed = JSON.parse(window.sessionStorage.getItem(exploredRoomsKey) || '[]');
    return new Set(parsed.map((id) => Number(id)).filter(Number.isInteger));
  } catch {
    return new Set();
  }
};

const saveExploredRooms = (roomIds) => {
  window.sessionStorage.setItem(exploredRoomsKey, JSON.stringify([...roomIds]));
};

const buildMapCoordinates = (roomsById, exploredIds, currentRoomId) => {
  const deltas = {
    north: [0, -1],
    south: [0, 1],
    east:  [1, 0],
    west:  [-1, 0],
    up:    [0, -1],
    down:  [0, 1],
  };

  const coordinates = new Map();
  const queue = [];

  if (exploredIds.has(currentRoomId)) {
    coordinates.set(currentRoomId, { x: 0, y: 0 });
    queue.push(currentRoomId);
  }

  while (queue.length > 0) {
    const roomId = queue.shift();
    const room = roomsById.get(roomId);
    const base = coordinates.get(roomId);
    if (!room || !base) continue;

    room.exits.forEach((exit) => {
      const destId = Number(exit.destination_id);
      if (!exploredIds.has(destId) || coordinates.has(destId)) return;

      const delta = deltas[String(exit.direction).toLowerCase()] || [1, 0];
      coordinates.set(destId, { x: base.x + delta[0], y: base.y + delta[1] });
      queue.push(destId);
    });
  }

  let index = 0;
  exploredIds.forEach((roomId) => {
    if (!coordinates.has(roomId)) {
      coordinates.set(roomId, { x: index, y: 3 });
      index += 1;
    }
  });

  return coordinates;
};

export const renderMinimap = () => {
  const mapDataNode = document.querySelector('#minimap-data');
  const canvas = document.querySelector('#minimap-canvas');
  if (!mapDataNode || !canvas) return;

  let mapData;
  try {
    mapData = JSON.parse(mapDataNode.textContent || '{}');
  } catch {
    return;
  }

  const rooms = Array.isArray(mapData.rooms) ? mapData.rooms : [];
  const currentRoomId = Number(mapData.current_room_id);
  if (!Number.isInteger(currentRoomId) || rooms.length === 0) return;

  const roomsById = new Map(rooms.map((r) => [Number(r.id), r]));
  const exploredIds = loadExploredRooms();
  exploredIds.add(currentRoomId);
  saveExploredRooms(exploredIds);

  const coordinates = buildMapCoordinates(roomsById, exploredIds, currentRoomId);
  const exploredRooms = rooms.filter((r) => exploredIds.has(Number(r.id)));

  canvas.innerHTML = '';

  const padding = 24;
  const viewWidth = 280;
  const viewHeight = 200;
  const usableWidth = viewWidth - padding * 2;
  const usableHeight = viewHeight - padding * 2;

  const xs = [...coordinates.values()].map((p) => p.x);
  const ys = [...coordinates.values()].map((p) => p.y);
  const minX = Math.min(...xs, 0);
  const maxX = Math.max(...xs, 0);
  const minY = Math.min(...ys, 0);
  const maxY = Math.max(...ys, 0);

  const mapToCanvas = (point) => ({
    x: padding + ((point.x - minX) / Math.max(maxX - minX, 1)) * usableWidth,
    y: padding + ((point.y - minY) / Math.max(maxY - minY, 1)) * usableHeight,
  });

  const createSvg = (name) => document.createElementNS('http://www.w3.org/2000/svg', name);
  const edgeKeys = new Set();

  exploredRooms.forEach((room) => {
    const roomId = Number(room.id);
    const fromPoint = coordinates.get(roomId);
    if (!fromPoint) return;

    const fromCanvas = mapToCanvas(fromPoint);

    room.exits.forEach((exit) => {
      const destId = Number(exit.destination_id);
      if (!exploredIds.has(destId)) return;

      const toPoint = coordinates.get(destId);
      if (!toPoint) return;

      const edgeKey = [roomId, destId].sort((a, b) => a - b).join('-');
      if (edgeKeys.has(edgeKey)) return;
      edgeKeys.add(edgeKey);

      const toCanvas = mapToCanvas(toPoint);
      const line = createSvg('line');
      line.setAttribute('x1', String(fromCanvas.x));
      line.setAttribute('y1', String(fromCanvas.y));
      line.setAttribute('x2', String(toCanvas.x));
      line.setAttribute('y2', String(toCanvas.y));
      line.setAttribute('class', 'minimap-edge');
      canvas.appendChild(line);
    });
  });

  exploredRooms.forEach((room) => {
    const roomId = Number(room.id);
    const point = coordinates.get(roomId);
    if (!point) return;

    const cp = mapToCanvas(point);
    const node = createSvg('circle');
    node.setAttribute('cx', String(cp.x));
    node.setAttribute('cy', String(cp.y));
    node.setAttribute('r', roomId === currentRoomId ? '8' : '5');
    node.setAttribute('class', roomId === currentRoomId ? 'minimap-node minimap-node-current' : 'minimap-node');
    canvas.appendChild(node);

    if (roomId === currentRoomId) {
      const label = createSvg('text');
      label.setAttribute('x', String(cp.x));
      label.setAttribute('y', String(cp.y - 12));
      label.setAttribute('text-anchor', 'middle');
      label.setAttribute('class', 'minimap-label');
      label.textContent = room.name;
      canvas.appendChild(label);
    }
  });
};
