package config

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
)

type Config struct {
	Url        string `json:"url"`
	HideCursor bool   `json:"hidecursor"`
	Port       uint16 `json:"port"`
}

type ProgramPath struct {
	Base string
}

func NewPath() (*ProgramPath, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return nil, err
	}

	return &ProgramPath{
		Base: filepath.Join(home, ".kioskipi"),
	}, nil
}

// return config file location
func (p *ProgramPath) Config() string {
	return filepath.Join(p.Base, "config.json")
}

func Exists() bool {
	path, _ := NewPath()
	_, err := os.Stat(path.Config())
	if os.IsNotExist(err) {
		return false
	}
	return true
}

func NewConfig(cData *Config) {
	jsonData, err := json.Marshal(cData)
	if err != nil {
		fmt.Printf("%v\n", jsonData)
	}

	path, _ := NewPath()

	err = os.WriteFile(path.Config(), jsonData, 0600)
	if err != nil {
		fmt.Println("No folder found, trying to create one")
		err = os.MkdirAll(path.Base, 0755)
		if err != nil {
			fmt.Println("Failed to create program folder")
			return
		}
		fmt.Println("Successfully created folder")

		NewConfig(cData)
	}
}

func Get() Config {
	path, err := NewPath()
	if err != nil {
		panic(err)
	}

	jsonFile, err := os.ReadFile(path.Config())
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

	path, err := NewPath()
	if err != nil {
		fmt.Println("path error: ", err)
		return
	}

	err = os.WriteFile(path.Config(), json, 0644)
	if err != nil {
		fmt.Println("path error: ", err)
		return
	}
}
