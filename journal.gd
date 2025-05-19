extends CanvasLayer

@onready var label = $JournalText
@onready var prev_button = $PrevButton
@onready var next_button = $NextButton
@onready var close_button = $CloseButton

var pages = [
	"Page 1: Caesar Cipher\nEach letter is shifted by a number, like +3 or -10.\nA + 3 = D, Z + 1 wraps to A.\nExample: HELLO with shift +1 → IFMMP.\nJust a basic letter rotation, easy to guess if the shift is known.",

	"Page 2: The Vigenère Cipher\nUnlike Caesar, this one uses a whole word to shift letters.\nIt's like stacking multiple Caesar ciphers.\n\nFor example, encrypting 'WATER' using key 'FIRE':\nW + F = B, A + I = I, T + R = K, E + E = I, R + F = W, So 'WATER' becomes 'BIKIW'.\n\nYou’ll need both the message and the keyword.",

	"Page 3: Atbash Cipher\nA mirrored alphabet cipher: A ↔ Z, B ↔ Y, C ↔ X...\nNo shifting or keys needed.\nExample: HELLO → SVOOL.\nIf it feels backwards, it probably is.",

	"Page 4: Substitution Cipher\nEach letter maps to a completely different one.\nThe 'key' is a shuffled alphabet (like A→Q, B→W, C→E...)\nExample: HELLO → WTAAD (if H=W, E=T, etc.)\nCrackable by letter frequency, but hard without a crib.",

	"Page 5: XOR Encryption\nEvery letter is converted to binary, then XOR’d with a key.\nXOR flips bits: 1 becomes 0 and 0 becomes 1 when paired with 1.\nIt’s reversible if you use the same key.\nMostly used in real encryption like software or files.",

	"Page 6: Base64 Encoding\nNot encryption — just hides raw data as readable text.\nIt uses A-Z, a-z, 0-9, +, / to encode binary.\nLooks like: VGhpcyBpcyBhIHRlc3Q= (means 'This is a test').\nEnds in = or == a lot. You’ll know it when you see it.",

	"Page 7: ROT13\nA Caesar Cipher with a fixed shift of 13 letters.\nA ↔ N, B ↔ O, C ↔ P... It loops halfway.\nExample: HELLO → URYYB.\nUsing it twice gives the original back: ROT13(ROT13(x)) = x.",

	"Page 8: Columnar Transposition\nWrite your message in rows under a keyword, then scramble columns.\nKey = LION, so columns are sorted alphabetically: I, L, N, O.\nRead down the new column order to get the cipher.\nHarder to spot since all the letters stay the same.",

	"Page 9: Playfair Cipher\nEncrypts pairs of letters using a 5x5 grid made from a keyword.\nIf letters are in same row: shift right. Same column: shift down.\nIf different row/col: make a rectangle and swap corners.\nNo duplicate letters allowed in the grid (I and J are usually merged).",

	"Page 10: RSA Formula\nm = c^d mod n — used to decrypt messages.\nc is the encrypted number (ciphertext).\nd is the private key (d = decrypt).\nm is the final decrypted result (the real message).\nn = modulus\nNeeds exact values. No guesswork here."
]

var current_page = 0

func _ready():
	update_page()
	hide()
	prev_button.pressed.connect(_on_prev_pressed)
	next_button.pressed.connect(_on_next_pressed)
	close_button.pressed.connect(_on_close_pressed)

func update_page():
	label.text = pages[current_page]
	prev_button.disabled = current_page == 0
	next_button.disabled = current_page == pages.size() - 1

func _on_prev_pressed():
	if current_page > 0:
		current_page -= 1
		update_page()

func _on_next_pressed():
	if current_page < pages.size() - 1:
		current_page += 1
		update_page()

func _on_close_pressed():
	get_tree().paused = false
	hide()

func _input(event):
	if event.is_action_pressed("toggle_journal"):
		if visible:
			_on_close_pressed()
		else:
			get_tree().paused = true
			show()
