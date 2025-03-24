use std::{
    borrow::Borrow,
    io::{Read, Write},
};

/// A munger which XORs a key with some data
#[derive(Clone)]
pub struct Xorcism<'a> {
    // This field is just to suppress compiler complaints;
    // feel free to delete it at any point.
    key: &'a [u8],
    index: usize,
}

impl<'a> Xorcism<'a> {
    /// Create a new Xorcism munger from a key
    ///
    /// Should accept anything which has a cheap conversion to a byte slice.
    pub fn new<Key: ?Sized + AsRef<[u8]>>(key: &'a Key) -> Xorcism<'a> {
        Xorcism {
            key: key.as_ref(),
            index: 0,
        }
    }

    /// XOR each byte of the input buffer with a byte from the key.
    ///
    /// Note that this is stateful: repeated calls are likely to produce different results,
    /// even with identical inputs.
    pub fn munge_in_place(&mut self, data: &mut [u8]) {
        for item in data {
            *item ^= self.key[self.index];
            self.index = (self.index + 1) % self.key.len();
        }
    }

    /// XOR each byte of the data with a byte from the key.
    ///
    /// Note that this is stateful: repeated calls are likely to produce different results,
    /// even with identical inputs.
    ///
    /// Should accept anything which has a cheap conversion to a byte iterator.
    /// Shouldn't matter whether the byte iterator's values are owned or borrowed.
    pub fn munge<Data>(&mut self, data: Data) -> impl Iterator<Item = u8>
    where
        Data: IntoIterator,
        Data::Item: Borrow<u8>,
    {
        data.into_iter().map(move |byte| {
            let key_byte = self.key[self.index];
            self.index = (self.index + 1) % self.key.len();
            byte.borrow() ^ key_byte
        })
    }

    pub fn reader(self, reader: impl Read) -> impl Read {
        XorReader {
            xorcism: self,
            reader,
        }
    }

    pub fn writer(self, writer: impl Write) -> impl Write {
        XorWriter {
            xorcism: self,
            writer,
        }
    }
}

pub struct XorReader<'a, R: Read> {
    xorcism: Xorcism<'a>,
    reader: R,
}

impl<R: Read> Read for XorReader<'_, R> {
    fn read(&mut self, buf: &mut [u8]) -> std::io::Result<usize> {
        let bytes_read = self.reader.read(buf)?;
        self.xorcism.munge_in_place(buf);
        Ok(bytes_read)
    }
}

pub struct XorWriter<'a, W: Write> {
    xorcism: Xorcism<'a>,
    writer: W,
}

impl<W: Write> Write for XorWriter<'_, W> {
    fn write(&mut self, buf: &[u8]) -> std::io::Result<usize> {
        let munged = self.xorcism.munge(buf).collect::<Vec<u8>>();
        self.writer.write(&munged)
    }

    fn flush(&mut self) -> std::io::Result<()> {
        self.writer.flush()
    }
}
