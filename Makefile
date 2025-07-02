# Variabili
ASM = as
LINKER = ld
TARGET = menu
SOURCE = menu.s
OBJECT = menu.o

# Cartelle
SRC_DIR = src
OBJ_DIR = obj
BIN_DIR = bin

# Percorsi completi
SOURCE_PATH = $(SRC_DIR)/$(SOURCE)
OBJECT_PATH = $(OBJ_DIR)/$(OBJECT)
TARGET_PATH = $(BIN_DIR)/$(TARGET)

# Flags
ASMFLAGS = --64
LDFLAGS = 

# Regola principale
all: $(TARGET_PATH)

# Compilazione e linking
$(TARGET_PATH): $(OBJECT_PATH) | $(BIN_DIR)
	$(LINKER) $(LDFLAGS) -o $(TARGET_PATH) $(OBJECT_PATH)

$(OBJECT_PATH): $(SOURCE_PATH) | $(OBJ_DIR)
	$(ASM) $(ASMFLAGS) -o $(OBJECT_PATH) $(SOURCE_PATH)

# Creazione delle cartelle se non esistono
$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

# Esecuzione
run: $(TARGET_PATH)
	./$(TARGET_PATH)

# Pulizia
clean:
	rm -f $(OBJECT_PATH) $(TARGET_PATH)
	rmdir $(OBJ_DIR) $(BIN_DIR) 2>/dev/null || true

# Pulizia completa (rimuove anche le cartelle)
distclean: clean
	rm -rf $(OBJ_DIR) $(BIN_DIR)

# debug
.PHONY: all clean distclean run