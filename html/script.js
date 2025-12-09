const container = document.getElementById('present-container');
const toField = document.getElementById('to-field');
const fromField = document.getElementById('from-field');
const giftSelect = document.getElementById('gift-select');
const stampImage = document.getElementById('stamp-image');
const presentImage = document.getElementById('present-image');
const fieldSelect = document.getElementById('field-select');
const fieldOpen = document.getElementById('field-open');

let inventoryItems = [];
let currentMode = 'create'; // 'create' or 'view'

// Listen for NUI messages from the client
window.addEventListener('message', function(event) {
    const data = event.data;

    switch(data.action) {
        case 'openUI':
            openUI(data.mode, data.inventory, data.metadata, data.mailStamp);
            break;
        case 'closeUI':
            closeUI();
            break;
    }
});

function openUI(mode, inventory, metadata, mailStamp) {
    currentMode = mode || 'create';

    // Set mail stamp image
    if (mailStamp) {
        stampImage.src = mailStamp;
    }

    if (currentMode === 'create') {
        // CREATE MODE - Empty present, editable fields, select dropdown
        presentImage.src = 'assets/EmptyPresent.png';

        // Store inventory and populate dropdown
        inventoryItems = inventory || [];
        populateGiftDropdown();

        // Clear previous values
        toField.value = '';
        fromField.value = '';
        giftSelect.value = '';

        // Make fields editable
        toField.readOnly = false;
        fromField.readOnly = false;

        // Show select, hide open button
        fieldSelect.classList.remove('hidden');
        fieldOpen.classList.add('hidden');

        // Focus on first field
        setTimeout(() => fromField.focus(), 100);
    } else {
        // VIEW MODE - Christmas present, read-only fields, open button
        presentImage.src = 'assets/ChristmasPresent.png';

        // Set field values from metadata
        toField.value = metadata.toName || '';
        fromField.value = metadata.fromName || '';

        // Make fields read-only
        toField.readOnly = true;
        fromField.readOnly = true;

        // Hide select, show open button
        fieldSelect.classList.add('hidden');
        fieldOpen.classList.remove('hidden');
    }

    // Show container
    container.classList.remove('hidden');
}

function closeUI() {
    container.classList.add('hidden');

    // Clear fields
    toField.value = '';
    fromField.value = '';
    giftSelect.value = '';
}

function populateGiftDropdown() {
    // Clear existing options except the first placeholder
    giftSelect.innerHTML = '<option value="">Select gift...</option>';

    // Group items by type
    const items = inventoryItems.filter(i => i.type === 'item');
    const weapons = inventoryItems.filter(i => i.type === 'weapon');
    const ammo = inventoryItems.filter(i => i.type === 'ammo');

    // Add regular items
    if (items.length > 0) {
        const itemGroup = document.createElement('optgroup');
        itemGroup.label = 'Items';
        items.forEach(item => {
            const option = document.createElement('option');
            option.value = item.name;
            option.textContent = `${item.label} (x${item.count})`;
            option.dataset.label = item.label;
            option.dataset.type = 'item';
            option.dataset.id = item.id;
            option.dataset.count = item.count;
            itemGroup.appendChild(option);
        });
        giftSelect.appendChild(itemGroup);
    }

    // Add weapons
    if (weapons.length > 0) {
        const weaponGroup = document.createElement('optgroup');
        weaponGroup.label = 'Weapons';
        weapons.forEach(item => {
            const option = document.createElement('option');
            option.value = item.name;
            option.textContent = item.label;
            option.dataset.label = item.label;
            option.dataset.type = 'weapon';
            option.dataset.id = item.id;
            option.dataset.count = 1;
            weaponGroup.appendChild(option);
        });
        giftSelect.appendChild(weaponGroup);
    }

    // Add ammo
    if (ammo.length > 0) {
        const ammoGroup = document.createElement('optgroup');
        ammoGroup.label = 'Ammo';
        ammo.forEach(item => {
            const option = document.createElement('option');
            option.value = item.name;
            option.textContent = `${item.label} (x${item.count})`;
            option.dataset.label = item.label;
            option.dataset.type = 'ammo';
            option.dataset.id = item.id;
            option.dataset.count = item.count;
            ammoGroup.appendChild(option);
        });
        giftSelect.appendChild(ammoGroup);
    }
}

function submitPresent() {
    const toName = toField.value.trim();
    const fromName = fromField.value.trim();
    const selectedItem = giftSelect.value;
    const selectedOption = giftSelect.options[giftSelect.selectedIndex];
    const selectedItemLabel = selectedOption ? selectedOption.dataset.label : selectedItem;
    const selectedType = selectedOption ? selectedOption.dataset.type : 'item';
    const selectedId = selectedOption ? selectedOption.dataset.id : null;
    const selectedCount = selectedOption ? parseInt(selectedOption.dataset.count) : 1;

    // Validate fields
    if (!fromName) {
        fromField.focus();
        shakeElement(fromField);
        return;
    }

    if (!toName) {
        toField.focus();
        shakeElement(toField);
        return;
    }

    if (!selectedItem) {
        giftSelect.focus();
        shakeElement(giftSelect);
        return;
    }

    // Gift entire stack for items and ammo, weapons are always 1
    const selectedAmount = (selectedType === 'weapon') ? 1 : selectedCount;

    // Send to client
    fetch(`https://${GetParentResourceName()}/createPresent`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            toName: toName,
            fromName: fromName,
            selectedItem: selectedItem,
            selectedItemLabel: selectedItemLabel,
            selectedType: selectedType,
            selectedId: selectedId,
            selectedAmount: selectedAmount
        })
    });
}

function openPresent() {
    // Send to client to open the present
    fetch(`https://${GetParentResourceName()}/openPresent`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
}

// Keyboard controls
document.addEventListener('keydown', function(event) {
    if (container.classList.contains('hidden')) return;

    // Enter to submit/open (but not when in textarea during create mode)
    if (event.key === 'Enter') {
        if (currentMode === 'view') {
            openPresent();
        } else if (event.target.tagName !== 'TEXTAREA') {
            submitPresent();
        }
    }

    // Escape to close
    if (event.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/closeUI`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({})
        });
    }
});

// Shake animation for invalid fields
function shakeElement(element) {
    element.style.animation = 'shake 0.5s ease';
    setTimeout(() => {
        element.style.animation = '';
    }, 500);
}

// Add shake animation to stylesheet
const style = document.createElement('style');
style.textContent = `
    @keyframes shake {
        0%, 100% { transform: translateX(0); }
        10%, 30%, 50%, 70%, 90% { transform: translateX(-5px); }
        20%, 40%, 60%, 80% { transform: translateX(5px); }
    }
`;
document.head.appendChild(style);
