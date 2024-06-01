use std::collections::HashMap;
use std::process::Command;
use walkdir::{DirEntry, WalkDir};
use regex::Regex;

//1 afficher toute la dir
//2 ouvrir une nouvelle dir et l afficher
//3 ouvrir un pdf et l'afficher
// 4 afficher tout les pdf dans l'arborecence
// 5 ajouter des notes sur un pdf
// 6 ajouter des icons sympa dans l arbo / pdf et trunc les extension de fichier
// 7 mettre en place un historique des livres lus pour faire un onglet fichier recents
// 8 mettre en place un systeme de recherche de fichier tah fzf

fn main() {
    let dir :&str = "books";
    while true {
        user_action();
    }

    display_dir(dir);

}

fn user_action() {
    println!("Enter a command : ");

    let mut input = String::new();
    std::io::stdin().read_line(&mut input).unwrap();
    let input = input.trim();

    match input {
        "q" => quit(),
        "h" => help(),
        _ => println!("Command not found"),
    }

}

fn display_dir(dir: &str) {
    let path_size = dir.len() + 1; // remove the "root" dir + /

    // get dirs
    let dirs: Vec<DirEntry> = get_dirs(dir);
    // truncate path

    // get pdfs
    let books: Vec<DirEntry> = get_books(dir);

    // display
    let mut i: u32 = 0;

    // concat dirs and books
    let mut all: Vec<DirEntry> = dirs.clone();
    all.extend(books.clone());

    all.iter()
        .filter(|e| e.path().to_str().unwrap().to_string() != dir.to_string())
        .for_each(|e| {
        let path = e.path().to_str().unwrap();
        let path = &path[path_size..];
        println!("{} {}", i, path);
        i += 1;
    });
}

fn get_dirs(dir: &str) -> Vec<DirEntry>{
    WalkDir::new(dir)
        .min_depth(0)
        .max_depth(1)
        .into_iter()
        .filter_map(|e| e.ok())
        .filter(|e| e.file_type().is_dir())
        .collect()
}

fn get_books(dir: &str) -> Vec<DirEntry>{
    WalkDir::new(dir)
        .min_depth(0)
        .max_depth(1)
        .into_iter()
        .filter_map(|e| e.ok())
        .filter(|e| e.file_type().is_file())
        .filter(|e| is_book(e))
        .collect()
}

fn is_book(e: &DirEntry) -> bool {
    let re = Regex::new(r".pdf$  | .md$ | .epub$ |").unwrap();
    re.is_match(e.path().to_str().unwrap())
}


fn help() {
        println!(" bibliotheue super cool, faire un hashset pour les commades pour faire des trucs propre / utiliser le truc de base de rust pour faire un cli super carré mais en vrai je ferais ca plus tard j veux apprendre sur le tasé");
}
fn quit() {
    println!("Ciao !");
    std::process::exit(0);
}