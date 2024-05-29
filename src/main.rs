use std::fs;
use std::path::PathBuf;
use std::process::Command;
use walkdir::{DirEntry, WalkDir};
use regex::Regex;

fn main() {
    let re = Regex::new(r".*\.pdf$").unwrap();
    let mut pdfs = Vec::new();

    for entry in WalkDir::new(".").into_iter().filter_map(|e| e.ok()) {
        if entry.file_type().is_file() && re.is_match(&entry.path().display().to_string()) {
            pdfs.push(entry);
        }
    }

    println!("Liste des PDF:");
    for (index, pdf) in pdfs.clone().into_iter().enumerate() {
        println!("{}: {}", index + 1, pdf.path().display());
    }

    // Attendre que l'utilisateur entre un index
    println!("Entrez l'index du PDF que vous souhaitez ouvrir:");
    let mut input = String::new();
    std::io::stdin().read_line(&mut input).expect("Erreur lors de la lecture de l'entrée");
    let index: usize = input.trim().parse().expect("Entrée invalide") - 1; // reduce by 1 to get the correct index

    // Ouvrir le PDF dans Firefox
    let path_to_pdf = &pdfs[index].path().display().to_string();
    Command::new("firefox")
        .arg(path_to_pdf)
        .spawn()
        .expect("Erreur lors de l'ouverture du PDF dans Firefox");
}
