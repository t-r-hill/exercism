pub struct Matrix {
    columns: usize,
    rows: usize,
    items: Vec<u32>,
}

impl Matrix {
    pub fn new(input: &str) -> Self {
        let columns = input.lines()
            .map(|line| line.split_whitespace())
            .next()
            .unwrap().count();

        let items : Vec<u32> = input.lines()
            .flat_map(|line| line.split_whitespace())
            .map(|item| item.parse::<u32>().unwrap())
            .collect();

        let rows = items.len() / columns;

        Matrix {
            columns,
            items,
            rows,
        }
    }

    pub fn row(&self, row_no: usize) -> Option<Vec<u32>> {
        if row_no > self.rows { return None; }
        let start = (row_no - 1) * self.columns;
        let end = start + self.columns;
        Some(self.items[start..end].to_vec().to_owned())
    }

    pub fn column(&self, col_no: usize) -> Option<Vec<u32>> {
        if col_no > self.columns { return None; }
        let start = col_no - 1;
        let step_size = self.columns;
        Some(self.items.iter().skip(start).step_by(step_size).copied().collect())
    }
}
