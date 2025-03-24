use std::collections::HashMap;

#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct InputCellId(usize);

#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct ComputeCellId(usize);

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct CallbackId(usize);

#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum CellId {
    Input(InputCellId),
    Compute(ComputeCellId),
}

#[derive(Debug, PartialEq, Eq)]
pub enum RemoveCallbackError {
    NonexistentCell,
    NonexistentCallback,
}

pub struct Reactor<'a, T> {
    input_cells: Vec<T>,
    compute_cells: Vec<ComputeCell<'a, T>>,
    callbacks: Callbacks<'a, T>,
}

struct ComputeCell<'a, T> {
    dependencies: Vec<CellId>,
    compute_function: Box<dyn Fn(&[T]) -> T + 'a>,
    value: T,
}

struct Callback<'a, T> {
    compute_cell: ComputeCellId,
    callback_function: Box<dyn FnMut(T) + 'a>,
}

struct Callbacks<'a, T> {
    callbacks: HashMap<usize, Callback<'a, T>>,
    next_id: usize,
}

impl<'a, T> Callbacks<'a, T> {
    fn new() -> Self {
        Callbacks {
            callbacks: HashMap::new(),
            next_id: 0,
        }
    }

    fn insert(&mut self, callback: Callback<'a, T>) -> usize {
        let id = self.next_id;
        self.callbacks.insert(id, callback);
        self.next_id += 1;
        id
    }

    fn remove(&mut self, id: usize) -> Option<Callback<T>> {
        self.callbacks.remove(&id)
    }
}

impl<'a, T: Copy + PartialEq> Reactor<'a, T> {
    pub fn new() -> Self {
        Reactor {
            input_cells: vec![],
            compute_cells: vec![],
            callbacks: Callbacks::new(),
        }
    }

    pub fn create_input(&mut self, _initial: T) -> InputCellId {
        self.input_cells.push(_initial);
        InputCellId(self.input_cells.len() - 1)
    }

    // Creates a compute cell with the specified dependencies and compute function.
    // The compute function is expected to take in its arguments in the same order as specified in
    // `dependencies`.
    // You do not need to reject compute functions that expect more arguments than there are
    // dependencies (how would you check for this, anyway?).
    //
    // If any dependency doesn't exist, returns an Err with that nonexistent dependency.
    // (If multiple dependencies do not exist, exactly which one is returned is not defined and
    // will not be tested)
    //
    // Notice that there is no way to *remove* a cell.
    // This means that you may assume, without checking, that if the dependencies exist at creation
    // time they will continue to exist as long as the Reactor exists.
    pub fn create_compute<F: Fn(&[T]) -> T + 'a>(
        &mut self,
        _dependencies: &[CellId],
        _compute_func: F,
    ) -> Result<ComputeCellId, CellId> {
        for &dependency in _dependencies {
            match dependency {
                CellId::Input(InputCellId(id)) => {
                    if self.input_cells.len() <= id {
                        return Err(dependency);
                    }
                }
                CellId::Compute(ComputeCellId(id)) => {
                    if self.compute_cells.len() <= id {
                        return Err(dependency);
                    }
                }
            }
        }
        let computed_value = self.compute(_dependencies, &_compute_func);
        self.compute_cells.push(ComputeCell {
            dependencies: _dependencies.to_vec(),
            compute_function: Box::new(_compute_func),
            value: computed_value,
        });
        Ok(ComputeCellId(self.compute_cells.len() - 1))
    }

    // Retrieves the current value of the cell, or None if the cell does not exist.
    //
    // You may wonder whether it is possible to implement `get(&self, id: CellId) -> Option<&Cell>`
    // and have a `value(&self)` method on `Cell`.
    //
    // It turns out this introduces a significant amount of extra complexity to this exercise.
    // We chose not to cover this here, since this exercise is probably enough work as-is.
    pub fn value(&self, id: CellId) -> Option<T> {
        match id {
            CellId::Input(InputCellId(id)) => self.input_cells.get(id).copied(),
            CellId::Compute(ComputeCellId(id)) => self.compute_cells.get(id).map(|cell| cell.value),
        }
    }

    // Sets the value of the specified input cell.
    //
    // Returns false if the cell does not exist.
    //
    // Similarly, you may wonder about `get_mut(&mut self, id: CellId) -> Option<&mut Cell>`, with
    // a `set_value(&mut self, new_value: T)` method on `Cell`.
    //
    // As before, that turned out to add too much extra complexity.
    pub fn set_value(&mut self, _id: InputCellId, _new_value: T) -> bool {
        let index = _id.0;
        if let Some(value) = self.input_cells.get_mut(index) {
            *value = _new_value;
            let mut changed_cells = HashMap::new();
            self.propagate(CellId::Input(_id), &mut changed_cells);
            self.process_callbacks(changed_cells);
            true
        } else {
            false
        }
    }

    fn propagate(&mut self, cell_id: CellId, changed_cells: &mut HashMap<CellId, (T, T)>) {
        let cell_ids_to_propagate = self
            .compute_cells
            .iter()
            .enumerate()
            .filter(|(_, cell)| cell.dependencies.contains(&cell_id))
            .map(|(index, _)| index)
            .collect::<Vec<_>>();

        for index in cell_ids_to_propagate {
            let cell = &self.compute_cells[index];
            let new_value = self.compute(&cell.dependencies, &cell.compute_function);

            if new_value != self.compute_cells[index].value {
                let init_value = self.compute_cells[index].value;
                changed_cells
                    .entry(CellId::Compute(ComputeCellId(index)))
                    .and_modify(|(_, new)| *new = new_value)
                    .or_insert((init_value, new_value));
                self.compute_cells[index].value = new_value;
            }

            self.propagate(CellId::Compute(ComputeCellId(index)), changed_cells);
        }
    }

    fn compute<F: Fn(&[T]) -> T + 'a + ?Sized>(
        &self,
        dependencies: &[CellId],
        compute_function: &F,
    ) -> T {
        let dependency_values = dependencies
            .iter()
            .map(|cell_id| match cell_id {
                &CellId::Input(InputCellId(index)) => self.input_cells[index],
                &CellId::Compute(ComputeCellId(index)) => self.compute_cells[index].value,
            })
            .collect::<Vec<_>>();
        compute_function(&dependency_values)
    }

    fn process_callbacks(&mut self, changed_cells: HashMap<CellId, (T, T)>) {
        changed_cells
            .iter()
            .filter(|(_, (old_value, new_value))| old_value != new_value)
            .filter_map(|(cell_id, (_, new_value))| match cell_id {
                CellId::Input(_) => None,
                CellId::Compute(compute_cell) => Some((compute_cell, new_value)),
            })
            .for_each(|(&compute_cell, &new_value)| {
                self.callbacks
                    .callbacks
                    .values_mut()
                    .filter(|callback| callback.compute_cell == compute_cell)
                    .for_each(|callback| {
                        (callback.callback_function)(new_value);
                    });
            });
    }

    // Adds a callback to the specified compute cell.
    //
    // Returns the ID of the just-added callback, or None if the cell doesn't exist.
    //
    // Callbacks on input cells will not be tested.
    //
    // The semantics of callbacks (as will be tested):
    // For a single set_value call, each compute cell's callbacks should each be called:
    // * Zero times if the compute cell's value did not change as a result of the set_value call.
    // * Exactly once if the compute cell's value changed as a result of the set_value call.
    //   The value passed to the callback should be the final value of the compute cell after the
    //   set_value call.
    pub fn add_callback<F: FnMut(T) + 'a>(
        &mut self,
        _id: ComputeCellId,
        _callback: F,
    ) -> Option<CallbackId> {
        if self.compute_cells.len() <= _id.0 {
            return None;
        }
        Some(CallbackId(self.callbacks.insert(Callback {
            compute_cell: _id,
            callback_function: Box::new(_callback),
        })))
    }

    // Removes the specified callback, using an ID returned from add_callback.
    //
    // Returns an Err if either the cell or callback does not exist.
    //
    // A removed callback should no longer be called.
    pub fn remove_callback(
        &mut self,
        cell: ComputeCellId,
        callback: CallbackId,
    ) -> Result<(), RemoveCallbackError> {
        if self.compute_cells.len() <= cell.0 {
            return Err(RemoveCallbackError::NonexistentCell);
        }
        if let Some(callback) = self.callbacks.remove(callback.0) {
            if callback.compute_cell == cell {
                return Ok(());
            } else {
                return Err(RemoveCallbackError::NonexistentCell);
            }
        }
        Err(RemoveCallbackError::NonexistentCallback)
    }
}
