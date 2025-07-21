package config

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"path/filepath"
)

type Config struct {
	Url        string `json:"url"`
	HideCursor bool   `json:"hidecursor"`
}

func Path() (string, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		log.Fatal(err)
	}

	return filepath.Join(home, ".kioskipi", "config.json"), nil
}

func Exists() bool {
	configFile, _ := Path()
	_, err := os.Stat(configFile)
	if os.IsNotExist(err) {
		return false
	}
	return true
}

func NewConfig() {
	data := Config{
		Url: "https://example.com",
	}

	jsonData, err := json.Marshal(data)
	if err != nil {
		fmt.Printf("%v\n", jsonData)
	}

	configFile, _ := Path()
	err = os.WriteFile(configFile, jsonData, 0600)
	if err != nil {
		panic(err)
	}
}

func Get() Config {
	configPath, err := Path()
	if err != nil {
		panic(err)
	}

	jsonFile, err := os.ReadFile(configPath)
	if err != nil {
		fmt.Println(err)
	}

	var data Config

	err = json.Unmarshal(jsonFile, &data)
	if err != nil {
		panic(err)
	}

	return data
}

func Save(c *Config) {
	json, err := json.Marshal(c)
	if err != nil {
		fmt.Println("error: ", err)
		return
	}

	path, err := Path()
	if err != nil {
		fmt.Println("path error: ", err)
		return
	}

	err = os.WriteFile(path, json, 0644)
	if err != nil {
		fmt.Println("path error: ", err)
		return
	}
}
