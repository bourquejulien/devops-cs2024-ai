type Map = Vec<Vec<u8>>;

pub struct Coordinates {
    pub(crate) x: f64,
    pub(crate) y: f64,
}

pub fn get_map(coords: &Coordinates, size: usize) -> Result<Map, String> {
    if size <= 1 {
        return Err("Size must be greater than or equal to 3".to_string());
    }

    if size % 2 == 0 {
        return Err("Map must be of odd size".to_string());
    }

    let num = ((coords.x + coords.y) * 1e5f64).floor() as i64;
    let digest = md5::compute(num.to_string());

    let mut map: Map = vec![vec![0; size]; size];

    for i in 0..size {
        for j in 0..size {
            if i == size / 2 && j == size / 2 {
                continue
            }

            let index = (i + j) % (digest.len() - 1);
            map[i][j] = digest[index];
        }
    }

    return Ok(map);
}
