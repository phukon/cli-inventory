package main

import (
	"encoding/json"
	"fmt"
	"github.com/rivo/tview"
	"log"
	"os"
	"strconv"
)

type Item struct {
	Name  string `json:"name"`
	Stock int    `json:"stock"`
}

var (
	inventory     = []Item{}
	inventoryFile = "inventory.json"
)

/**
Functions
- Load inventory from json file
- Save inventory
- Delete item from inventory
*/

func loadInventory() {
	if _, err := os.Stat(inventoryFile); err == nil {
		{
			data, err := os.ReadFile(inventoryFile)
			if err != nil {
				log.Fatal("Error reading inventory file! - ", err)
			}
			json.Unmarshal(data, &inventory)
		}
	}
}

func saveInventory() {
	data, err := json.MarshalIndent(inventory, "", " ")
	if err != nil {
		log.Fatal("Error saving inventory! - ", err)
	}
	os.WriteFile(inventoryFile, data, 0644) // also creates a new file if it doesn't exists
}

func deleteItem(index int) {
	if index < 0 || index >= len(inventory) {
		fmt.Println("Invalid item index")
		return
	}

	inventory = append(inventory[:index], inventory[index+1:]...)
	saveInventory()
}

func main() {
	// the tui app
	app := tview.NewApplication()
	loadInventory()
	inventoryList := tview.NewTextView().SetDynamicColors(true).SetWordWrap(true)

	inventoryList.SetBorder(true).SetTitle("Inventory List")

	refreshInventory := func() {
		inventoryList.Clear()
		if len(inventory) == 0 {
			fmt.Fprintln(inventoryList, "No items in the inventory")
		} else {
			for index, item := range inventory {
				fmt.Fprintf(inventoryList, "[%d] %s (Stock: %d)\n", index+1, item.Name, item.Stock)
			}
		}
	}

	// input fields
	itemNameInput := tview.NewInputField().SetLabel("Item Name: ")
	itemStockInput := tview.NewInputField().SetLabel("Item Stock: ")
	itemIdInput := tview.NewInputField().SetLabel("Item ID: ")

	form := tview.NewForm().
		AddFormItem(itemNameInput).
		AddFormItem(itemStockInput).
		AddFormItem(itemIdInput).
		AddButton("Add Item", func() {
			name := itemNameInput.GetText()
			stock := itemStockInput.GetText()

			if name != "" && stock != "" {
				quantity, err := strconv.Atoi(stock)
				if err != nil {
					fmt.Println("Invalid stock value")
					return
				}
				inventory = append(inventory, Item{Name: name, Stock: quantity})
				saveInventory()
				refreshInventory()
				itemNameInput.SetText("")
				itemStockInput.SetText("")
				itemIdInput.SetText("")
			}
		}).
		AddButton("Delete Item", func() {
			idString := itemIdInput.GetText()
			if idString == "" {
				fmt.Fprintf(inventoryList, "Please enter an item ID to delete an item\n")
				return
			}

			id, err := strconv.Atoi(idString)
			if err != nil || id < 1 || id > len(inventory) {
				fmt.Fprintf(inventoryList, "Invalid Item ID")
				return
			}
			deleteItem(id - 1)
			fmt.Fprintf(inventoryList, "Item [%d] has been deleted from the inventory\n", id)
			refreshInventory()
			itemIdInput.SetText("")
		}).AddButton("Exit", func() { // Button to exit the application
		app.Stop()
	})

	form.SetBorder(true).SetTitle("Manage Inventory").SetTitleAlign(tview.AlignLeft)
	flex := tview.NewFlex().AddItem(form, 0, 1, true).AddItem(inventoryList, 0, 2, false)
	refreshInventory()
	if err := app.SetRoot(flex, true).Run(); err != nil {
		log.Fatal(err)
	}

}
