#!/bin/bash

repertoire="/home/jlss/files/etudes/Readings"

# Fonction pour afficher les livres non lus
afficher_livres_non_lus() {
	echo "Livres non lus :"
	local index=1
	while IFS= read -r -d '' livre; do
		livre_relatif="${livre#$repertoire/}"
		livres_non_lus[$index]="$livre_relatif"
		echo "$index. $livre_relatif"
		((index++))
	done < <(find "$repertoire" -type f -name "*.pdf" -print0)
	echo
}

# Fonction pour afficher les catégories de livres
afficher_categories() {
	echo "Catégories de livres :"
	local index=1
	while IFS= read -r -d '' categorie; do
		categorie_relatif="${categorie#$repertoire/}"
		categories[$index]="$categorie_relatif"
		echo "$index. $categorie_relatif"
		((index++))
	done < <(find "$repertoire" -type d -print0 | sed '1d')
	echo
}

# Fonction pour afficher les livres d'une catégorie
afficher_livres_categorie() {
	local categorie="${categories[$1]}"
	echo "Livres de la catégorie $categorie :"
	local index=1
	while IFS= read -r -d '' livre; do
		livre_relatif="${livre#$repertoire/}"
		livres_categorie[$index]="$livre_relatif"
		echo "$index. $livre_relatif"
		((index++))
	done < <(find "$repertoire/$categorie" -type f -name "*.pdf" -print0)
	echo
}

# Fonction pour ouvrir un livre
ouvrir_livre() {
	local index="$1"
	local livre="${livres_non_lus[$index]}"
	livre_absolu="$repertoire/$livre"
	echo "Ouverture du livre $livre_absolu..."
	firefox "$livre_absolu" &
	echo
}

# Fonction pour marquer un livre comme lu
marquer_livre_lu() {
	local index="$1"
	local livre="${livres_non_lus[$index]}"
	echo "$livre" >>"$repertoire/bd"
	echo "Le livre $livre a été marqué comme lu."
	echo
}

# Fonction pour stocker l'avancée dans un livre
stocker_avancee() {
	local index="$1"
	local livre="${livres_non_lus[$index]}"
	echo "Entrez votre avancée dans le livre $livre :"
	read avancee
	echo "Avancée : $avancee" >>"$repertoire/avancee.txt"
	echo "L'avancée dans le livre $livre a été enregistrée."
	echo
}

# Fonction pour consulter l'avancée d'un livre
consulter_avancee() {
	local index="$1"
	local livre="${livres_non_lus[$index]}"
	echo "Avancée dans le livre $livre :"
	grep -A 1 "$livre" "$repertoire/avancee.txt"
	echo
}

# Menu principal
while true; do
	echo "=== Menu principal ==="
	echo "1. Afficher les livres non lus"
	echo "2. Parcourir les catégories de livres"
	echo "3. Quitter"
	read choix

	case $choix in
	1)
		afficher_livres_non_lus
		echo "Que souhaitez-vous faire ?"
		echo "Entrez le numéro du livre que vous souhaitez sélectionner (ou 'q' pour quitter) :"
		read selection

		if [[ $selection == "q" ]]; then
			continue
		fi

		if [[ ${livres_non_lus[$selection]+_} ]]; then
			echo "1. Ouvrir le livre"
			echo "2. Marquer le livre comme lu"
			echo "3. Stocker votre avancée dans le livre"
			echo "4. Consulter l'avancée du livre"
			echo "5. Retour au menu principal"
			read action

			case $action in
			1)
				ouvrir_livre "$selection"
				;;
			2)
				marquer_livre_lu "$selection"
				;;
			3)
				stocker_avancee "$selection"
				;;
			4)
				consulter_avancee "$selection"
				;;
			5)
				continue
				;;
			*)
				echo "Choix invalide."
				;;
			esac
		else
			echo "Choix invalide."
		fi
		;;
	2)
		afficher_categories
		echo "Entrez le numéro de la catégorie que vous souhaitez parcourir (ou 'q' pour quitter) :"
		read selection

		if [[ $selection == "q" ]]; then
			continue
		fi

		if [[ ${categories[$selection]+_} ]]; then
			categorie="${categories[$selection]}"
			afficher_livres_categorie "$selection"
			echo "Que souhaitez-vous faire ?"
			echo "Entrez le numéro du livre que vous souhaitez ouvrir (ou 'q' pour quitter) :"
			read livre_selection

			if [[ $livre_selection == "q" ]]; then
				continue
			fi

			if [[ ${livres_categorie[$livre_selection]+_} ]]; then
				livre="${livres_categorie[$livre_selection]}"
				livre_absolu="$repertoire/$categorie/$livre"
				echo "Ouverture du livre $livre_absolu..."
				firefox "$livre_absolu" &
				echo
			else
				echo "Choix invalide."
			fi
		else
			echo "Choix invalide."
		fi
		;;
	3)
		echo "Au revoir !"
		exit 0
		;;
	*)
		echo "Choix invalide."
		;;
	esac
done
