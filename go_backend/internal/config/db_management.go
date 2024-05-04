package config

import (
	"database/sql"
	"os"

	_ "github.com/go-sql-driver/mysql" // MySQL driver

	"github.com/tanimutomo/sqlfile"
    "github.com/joho/godotenv"

	"log"
)

const (
	dbName   = "pharmacist_app"
)

var DB *sql.DB

func OpenDB() error {
    if err := godotenv.Load("../.env"); err != nil {
        log.Fatal("Error loading .env file")
    }

    dbDriver := os.Getenv("DB_DRIVER")
    dbUser := os.Getenv("DB_USER")
    dbPass := os.Getenv("DB_PASS")

	var err error
	DB, err = sql.Open(dbDriver, dbUser+":"+dbPass+"@/"+dbName)
	if err != nil {
		return err
	}
	return nil
}

func CloseDB() error {
	if err := DB.Close(); err != nil {
		return err
	}
	return nil
}

func ResetDatabase() {
	var err error
	_, err = DB.Exec("DROP DATABASE IF EXISTS " + dbName)
	if err != nil {
		log.Fatal(err)
	}

	_, err = DB.Exec("CREATE DATABASE " + dbName)
	if err != nil {
		log.Fatal(err)
	}

	_, err = DB.Exec("USE " + dbName)
	if err != nil {
		log.Fatal(err)
	}

	s := sqlfile.New()
	err = s.File("internal/config/database_schema.sql")
	if err != nil {
		log.Fatal(err)
	}

	_, err = s.Exec(DB)
	if err != nil {
		log.Fatal(err)
	}
	RemoveImagesDir()
}

func PopulateDatabase() {
	_, err := DB.Exec(`INSERT INTO pharmacies (name, address, image_path) VALUES
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
	_, err = DB.Exec(`INSERT INTO users (username, password) VALUES
		("admin", "1234")
	`)
	if err != nil {
		log.Fatal(err)
	}

	PopulateImagesDir()
}

func PopulateImagesDir() {
	// get all pharmacies images path
	rows, err := DB.Query("SELECT image_path FROM pharmacies")
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
