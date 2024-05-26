package services

import (
	"encoding/base64"
	"go_backend/internal/config"
	"go_backend/internal/database"
	models "go_backend/internal/models"
	"log"
	"os"
)

func PopulateDatabase() {
	_, err := config.DB.Exec(`INSERT INTO pharmacies (name, address, image_path) VALUES
		("Alegro Montijo", "Zona Industrial do Pau Queimado, Rua da Azinheira 1, Montijo", "internal/images/pharmacies/AlegroMontijo.png"),
		("Farmácialegria", "Estrada de Benfica 180A B, Lisboa", "internal/images/pharmacies/Farmacialegria.png"),
		("Intermarché Famões", "Avenida Casal do Segolim lote EA-01, Famões", "internal/images/pharmacies/IntermarcheFamoes.png"),
		("Farmácia Esperança", "Rua Carlos Mardel 101 - B, Lisboa", "internal/images/pharmacies/FarmaciaEsperanca.png"),
		("SEMBLANO & MENDES, LDA", "Rua Eduardo Viana 26A Fracção L, Almada", "internal/images/pharmacies/SEMBLANO&MENDES,LDA.png"),
		("FARMÁCIA MELO", "Praça Dom João I Nº 9 B, Amadora", "internal/images/pharmacies/FARMACIAMELO.png"),
		("Farmácia Nova Iorque", "Avenida dos Estados Unidos da América 142 B/C, Lisboa", "internal/images/pharmacies/FarmaciaNovaIorque.png"),
		("Farmácia Famões", "Rua José António Carvalho 16E, Famões", "internal/images/pharmacies/FarmaciaFamoes.png"),
		("FARMÁCIA SARAIVA", "Rua da República 86, Loures", "internal/images/pharmacies/FARMACIASARAIVA.png"),
		("Farmácia Santo Amaro", "Rua Filinto Elísio 29B, Lisboa", "internal/images/pharmacies/FarmaciaSantoAmaro.png"),
		("Farmácia Castro Sucr.", "Rua de São Bento 199A, Lisboa", "internal/images/pharmacies/FarmaciaCastroSucr.png"),
		("Farmácia Pimenta", "Rua Conselheiro Joaquim António D'Aguiar 259, Barreiro", "internal/images/pharmacies/FarmaciaPimenta.png"),
		("Farmácia Marques", "Estrada de Benfica 648, Lisboa", "internal/images/pharmacies/FarmaciaMarques.png"),
		("Farmácia Monserrate", "Rua Guilherme Gomes Fernandes 31, Odivelas", "internal/images/pharmacies/FarmaciaMonserrate.png"),
		("Farmácia Santarita", "Avenida Bombeiros Voluntários de Algés 80A, Lisboa", "internal/images/pharmacies/FarmaciaSantarita.png"),
		("Farmácia Amadora-Sintra", "Avenida Conde de Oeiras 12C, Amadora", "internal/images/pharmacies/FarmaciaAmadora-Sintra.png"),
		("Farmácia Imperial (Farmácias Progresso)", "Avenida Guerra Junqueiro 30B, Lisboa", "internal/images/pharmacies/FarmaciaImperial(FarmaciasProgresso).png"),
		("Farmácia Damaia", "Largo Alexandre Gusmão 9A, Amadora", "internal/images/pharmacies/FarmaciaDamaia.png"),
		("Farmácia Batalha, Lda.", "Rua Avelino Salgado de Oliveira 8A, Camarate", "internal/images/pharmacies/FarmaciaBatalha,Lda.png"),
		("Farmácia Gusmão", "Rua Cândido dos Reis 30, Alhos Vedros", "internal/images/pharmacies/FarmaciaGusmao.png"),
		("Pharmacy Carenque", "Estrada Águas Livres 120B, Amadora", "internal/images/pharmacies/PharmacyCarenque.png"),
		("Ivone", "Rua Silva Carvalho 232c, Lisboa", "internal/images/pharmacies/Ivone.png"),
		("Farmácia Conceição Lda.", "Calçada Dom Gastão 29B, Lisboa", "internal/images/pharmacies/FarmaciaConceicaoLda.png"),
		("Farmácia do Guizo", "Urbanização do, Rua Moinho do Guizo lote A6 Piso 0 6 loja a, Amadora", "internal/images/pharmacies/FarmaciadoGuizo.png"),
		("Farmácia Vaz Martins", "Praceta Fernando Pessoa 5", "internal/images/pharmacies/FarmaciaVazMartins.png"),
		("Farmácia Antunes Rosas", "Praça Cidade São Salvador 199, Lisboa", "internal/images/pharmacies/FarmaciaAntunesRosas.png"),
		("Espaço de Saúde da Paiã", "Rua Major João Luís de Moura 11, Pontinha", "internal/images/pharmacies/EspacodeSaudedaPaia.png"),
		("Pragal Pharmacy Ltd.", "Rua Direita 6, Almada", "internal/images/pharmacies/PragalPharmacyLtd.png"),
		("Farmácia de Marvila", "Rua Eduarda Lapa Lote 35, Lisboa", "internal/images/pharmacies/FarmaciadeMarvila.png"),
		("Farmácia Seixal", "Avenida Vasco da Gama 15, Seixal", "internal/images/pharmacies/FarmaciaSeixal.png"),
		("Farmácia Confiança", "Avenida Dom Nuno Álvares Pereira 15A, Amadora", "internal/images/pharmacies/FarmaciaConfianca.png"),
		("Pharmacy Ribeiro Soares", "Rua Dom Pedro V 39, Santa Iria de Azoia", "internal/images/pharmacies/PharmacyRibeiroSoares.png"),
		("Farmácia Higiénica", "Rua dos Marinheiros 60, Póvoa de Santa Iria", "internal/images/pharmacies/FarmaciaHigienica.png"),
		("Farmácia Marques Freire", "Rua Santo António à Estrela 98, Lisboa", "internal/images/pharmacies/FarmaciaMarquesFreire.png"),
		("Farmácia do Monte", "Rua da Graça 82A, Lisboa", "internal/images/pharmacies/FarmaciadoMonte.png"),
		("Farmácia Santa Marta", "Rua Doutor Manuel Pacheco Nobre 44B, Barreiro", "internal/images/pharmacies/FarmaciaSantaMarta.png"),
		("Farmácia Sírius", "Rua Fialho de Almeida 38, Lisboa", "internal/images/pharmacies/FarmaciaSirius.png"),
		("Farmácia Silva Monteiro", "Portugal", "internal/images/pharmacies/FarmaciaSilvaMonteiro.png"),
		("Farmácia Cruz Correia", "Rua de Santo Eloy 41 A, Pontinha", "internal/images/pharmacies/FarmaciaCruzCorreia.png"),
		("Farmácia Tanara Amadora", "Avenida Doutor Armando Romão 3A, Amadora", "internal/images/pharmacies/FarmaciaTanaraAmadora.png")
	`)
	if err != nil {
		log.Fatal(err)
	}
	_, err = config.DB.Exec(`INSERT INTO users (username, password) VALUES
		("admin", "1234")
	`)
	if err != nil {
		log.Fatal(err)
	}

	medicinePicture, err := os.ReadFile("internal/images/stock_photos/paracetamol.png")
	if err != nil {
		log.Fatal(err)
	}
	picture := base64.StdEncoding.EncodeToString(medicinePicture)

	for i := 1; i <= 10; i++ {
		var medicine = models.Medicine{
			Id:         0,
			Name:       "Paracetamol",
			Details:    "Paracetamol is a pain reliever and a fever reducer. Paracetamol is used to treat many conditions such as headache, muscle aches, arthritis, backache, toothaches, colds, and fevers. It relieves pain in mild arthritis but has no effect on the underlying inflammation and swelling of the joint.",
			Stock:      100 + i,
			PharmacyId: i,
			Picture:    picture,
			Barcode:    "1234567890123",
		}
		database.AddMedicine(medicine)
	}

	PopulateImagesDir()
}

func PopulateImagesDir() {
	// get all pharmacies images path
	rows, err := config.DB.Query("SELECT image_path FROM pharmacies")
	if err != nil {
		log.Fatal(err)
	}
	// for each image path, save stock image in that path
	for rows.Next() {
		var imagePath string
		err := rows.Scan(&imagePath)
		if err != nil {
			log.Fatal(err)
		}

		// save stock image
		imageData, err := os.ReadFile("internal/images/stock_photos/pharmacy.png")
		if err != nil {
			log.Fatal(err)
		}

		// copy stock image to image path
		err = os.WriteFile(imagePath, imageData, 0644)
		if err != nil {
			log.Fatal(err)
		}
	}
}
