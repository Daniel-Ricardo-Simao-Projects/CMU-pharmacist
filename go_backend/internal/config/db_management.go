package config

import (
	"database/sql"
	_ "github.com/go-sql-driver/mysql" // MySQL driver

	"github.com/tanimutomo/sqlfile"

	"log"
)

const (
	dbDriver = "mysql"
	dbUser   = "root"
	dbPass   = "mysql"
	dbName   = "pharmacist_app"
)

var DB *sql.DB

func OpenDB() error {
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
		("Alegro Montijo", "Zona Industrial do Pau Queimado, Rua da Azinheira 1, Montijo", "internal/images/pharmacies/AlegroMontijo"),
		("Farmácialegria", "Estrada de Benfica 180A B, Lisboa", "internal/images/pharmacies/Farmacialegria"),
		("Intermarché Famões", "Avenida Casal do Segolim lote EA-01, Famões", "internal/images/pharmacies/IntermarcheFamoes"),
		("Farmácia Esperança", "Rua Carlos Mardel 101 - B, Lisboa", "internal/images/pharmacies/FarmaciaEsperanca"),
		("SEMBLANO & MENDES, LDA", "Rua Eduardo Viana 26A Fracção L, Almada", "internal/images/pharmacies/SEMBLANO&MENDES,LDA"),
		("FARMÁCIA MELO", "Praça Dom João I Nº 9 B, Amadora", "internal/images/pharmacies/FARMACIAMELO"),
		("Farmácia Nova Iorque", "Avenida dos Estados Unidos da América 142 B/C, Lisboa", "internal/images/pharmacies/FarmaciaNovaIorque"),
		("Farmácia Famões", "Rua José António Carvalho 16E, Famões", "internal/images/pharmacies/FarmaciaFamoes"),
		("FARMÁCIA SARAIVA", "Rua da República 86, Loures", "internal/images/pharmacies/FARMACIASARAIVA"),
		("Farmácia Santo Amaro", "Rua Filinto Elísio 29B, Lisboa", "internal/images/pharmacies/FarmaciaSantoAmaro"),
		("Farmácia Castro Sucr.", "Rua de São Bento 199A, Lisboa", "internal/images/pharmacies/FarmaciaCastroSucr."),
		("Farmácia Pimenta", "Rua Conselheiro Joaquim António D'Aguiar 259, Barreiro", "internal/images/pharmacies/FarmaciaPimenta"),
		("Farmácia Marques", "Estrada de Benfica 648, Lisboa", "internal/images/pharmacies/FarmaciaMarques"),
		("Farmácia Monserrate", "Rua Guilherme Gomes Fernandes 31, Odivelas", "internal/images/pharmacies/FarmaciaMonserrate"),
		("Farmácia Santarita", "Avenida Bombeiros Voluntários de Algés 80A, Lisboa", "internal/images/pharmacies/FarmaciaSantarita"),
		("Farmácia Amadora-Sintra", "Avenida Conde de Oeiras 12C, Amadora", "internal/images/pharmacies/FarmaciaAmadora-Sintra"),
		("Farmácia Imperial (Farmácias Progresso)", "Avenida Guerra Junqueiro 30B, Lisboa", "internal/images/pharmacies/FarmaciaImperial(FarmaciasProgresso)"),
		("Farmácia Damaia", "Largo Alexandre Gusmão 9A, Amadora", "internal/images/pharmacies/FarmaciaDamaia"),
		("Farmácia Batalha, Lda.", "Rua Avelino Salgado de Oliveira 8A, Camarate", "internal/images/pharmacies/FarmaciaBatalha,Lda."),
		("Pharmacy Carenque", "Estrada Águas Livres 120B, Amadora", "internal/images/pharmacies/PharmacyCarenque"),
		("Pharmacy Carenque", "Estrada Águas Livres 120B, Amadora", "internal/images/pharmacies/PharmacyCarenque"),
		("Ivone", "Rua Silva Carvalho 232c, Lisboa", "internal/images/pharmacies/Ivone"),
		("Farmácia Conceição Lda.", "Calçada Dom Gastão 29B, Lisboa", "internal/images/pharmacies/FarmaciaConceicaoLda."),
		("Farmácia do Guizo", "Urbanização do, Rua Moinho do Guizo lote A6 Piso 0 6 loja a, Amadora", "internal/images/pharmacies/FarmaciadoGuizo"),
		("Farmácia Vaz Martins", "Praceta Fernando Pessoa 5", "internal/images/pharmacies/FarmaciaVazMartins"),
		("Farmácia Antunes Rosas", "Praça Cidade São Salvador 199, Lisboa", "internal/images/pharmacies/FarmaciaAntunesRosas"),
		("Espaço de Saúde da Paiã", "Rua Major João Luís de Moura 11, Pontinha", "internal/images/pharmacies/EspacodeSaudedaPaia"),
		("Pragal Pharmacy Ltd.", "Rua Direita 6, Almada", "internal/images/pharmacies/PragalPharmacyLtd."),
		("Farmácia de Marvila", "Rua Eduarda Lapa Lote 35, Lisboa", "internal/images/pharmacies/FarmaciadeMarvila"),
		("Farmácia Seixal", "Avenida Vasco da Gama 15, Seixal", "internal/images/pharmacies/FarmaciaSeixal"),
		("Farmácia Confiança", "Avenida Dom Nuno Álvares Pereira 15A, Amadora", "internal/images/pharmacies/FarmaciaConfianca"),
		("Pharmacy Ribeiro Soares", "Rua Dom Pedro V 39, Santa Iria de Azoia", "internal/images/pharmacies/PharmacyRibeiroSoares"),
		("Farmácia Higiénica", "Rua dos Marinheiros 60, Póvoa de Santa Iria", "internal/images/pharmacies/FarmaciaHigienica"),
		("Farmácia Marques Freire", "Rua Santo António à Estrela 98, Lisboa", "internal/images/pharmacies/FarmaciaMarquesFreire"),
		("Farmácia do Monte", "Rua da Graça 82A, Lisboa", "internal/images/pharmacies/FarmaciadoMonte"),
		("Farmácia Santa Marta", "Rua Doutor Manuel Pacheco Nobre 44B, Barreiro", "internal/images/pharmacies/FarmaciaSantaMarta"),
		("Farmácia Sírius", "Rua Fialho de Almeida 38, Lisboa", "internal/images/pharmacies/FarmaciaSirius"),
		("Farmácia Cruz Correia", "Rua de Santo Eloy 41 A, Pontinha", "internal/images/pharmacies/FarmaciaCruzCorreia"),
		("Farmácia Tanara Amadora", "Avenida Doutor Armando Romão 3A, Amadora", "internal/images/pharmacies/FarmaciaTanaraAmadora")
	`)
	if err != nil {
		log.Fatal(err)
	}
}
