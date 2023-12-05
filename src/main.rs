use std::{
    collections::HashMap,
    env,
    error::Error,
    fs,
    io::{BufRead, BufReader, BufWriter},
    result,
};

use bincode::serialize_into;

type Result<T> = result::Result<T, Box<dyn Error>>;

fn read_file(input_path: &str) -> Result<HashMap<String, Vec<f64>>> {
    let mut dists = HashMap::new();
    let mut is_name_line = true;

    for line in BufReader::new(fs::File::open(input_path)?).lines() {
        let line = line?;
        let last_name = if is_name_line {
            line.trim().to_string()
        } else {
            String::new()
        };

        let distances: Vec<f64> = if !is_name_line {
            line.trim()
                .split_whitespace()
                .map(|s| s.parse::<f64>().unwrap())
                .collect()
        } else {
            Vec::new()
        };

        dists.insert(last_name, distances);
        is_name_line = !is_name_line;
    }

    Ok(dists)
}

fn write_file(output_path: &str, dists: &HashMap<String, Vec<f64>>) -> Result<()> {
    let mut writer = BufWriter::new(fs::File::create(output_path)?);
    serialize_into(&mut writer, dists)?;

    eprintln!("Serialization successful");
    Ok(())
}

fn main() -> Result<()> {
    let args: Vec<String> = env::args().collect();
    if args.len() != 3 {
        eprintln!("Usage: {} <input_path> <output_path>", args[0]);
        std::process::exit(1);
    }

    let (input_path, output_path) = (&args[1], &args[2]);
    let dists = read_file(input_path)?;
    write_file(output_path, &dists)?;

    Ok(())
}
