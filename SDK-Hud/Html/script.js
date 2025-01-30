window.addEventListener('message', function(event) {
    const data = event.data;
    const hudContainer = document.querySelector('.hud-container');
    const vehicleHud = document.querySelector('.vehicle-hud');
    const seatbeltSound = new Audio('seatbelt.wav');
    let seatbelt = vehicleHud.querySelector('.seatbelt')

    switch(data.type) {
        case 'updateStatus':
            Object.entries({
                health: data.health,
                armor: data.armor,
                hunger: data.hunger,
                thirst: data.thirst,
                stamina: data.stamina,
                voice: data.voiceRange * 33.33
            }).forEach(([stat, value]) => {
                const element = document.querySelector(`.${stat}`);
                if (!element) return;
                
                const fill = element.querySelector('.fill');
                const valueEl = element.querySelector('.value, .percentage');
                value = Math.max(0, Math.min(100, Math.round(value)));
                
                if (fill) {
                    fill.style.width = `${value}%`;
                    element.dataset.value = value;
                }
                
                if (valueEl) valueEl.textContent = `${value}%`;
                if (stat === 'armor') element.style.display = value > 0 ? 'flex' : 'none';
                
            });

            const voiceIcon = document.querySelector('.voice i');
            if (voiceIcon) {
                voiceIcon.style.color = data.isTalking ? '#ffff00' : '#ffffff';
                voiceIcon.style.transform = data.isTalking ? 'scale(1.1)' : 'scale(1)';
            }
            
            hudContainer.classList.toggle('radar-active', data.showRadar);
            if (data.playerId) {
                document.querySelector('.id-value').textContent = data.playerId;
            }
            break;
            
        case 'updateVehicle':
            if (vehicleHud) {
                vehicleHud.classList.add('active');
                const elements = {
                    speed: vehicleHud.querySelector('.speed-value'),
                    gear: vehicleHud.querySelector('.gear'),
                    speedGauge: vehicleHud.querySelector('.speed-gauge .fill'),
                    fuelGauge: vehicleHud.querySelector('.fuel-gauge .fill'),
                    speedUnit: vehicleHud.querySelector('.speed-unit'),
                };

                const seatbelt = vehicleHud.querySelector('.seatbelt');
                if (seatbelt) {
                    seatbelt.style.display = data.seatbeltEnabled ? 'block' : 'none';
                }
                if (elements.speed) elements.speed.textContent = Math.round(data.speed);
                if (elements.gear) elements.gear.textContent = data.gear || 'N';
                if (elements.speedUnit) elements.speedUnit.textContent = data.useKMH ? 'KM/H' : 'MPH';
                
                if (elements.speedGauge) {
                    const percentage = (data.speed / data.maxSpeed) * 100;
                    elements.speedGauge.style.width = `${Math.min(percentage, 100)}%`;
                }
                
                if (elements.fuelGauge) {
                    elements.fuelGauge.style.width = `${data.fuel}%`;
                    elements.fuelGauge.parentElement.classList.toggle('low', data.fuel < 20);
                }

            }
            break;
            
        case 'hideVehicleHUD':
            if (vehicleHud) {
                vehicleHud.classList.remove('active');
            }
            break;
            
        case 'updateSeatbelt':
            if (seatbelt) {
                seatbelt.classList.toggle('active', data.seatbelt);
                if (data.seatbelt) {
                    seatbelt.innerHTML = '<i class="fa-solid fa-bell"></i>';
                } else {
                    seatbelt.innerHTML = '<i class="fa-solid fa-bell-slash"></i>';
                }
                seatbeltSound.play();
            }
            break;
        case 'updateSeatbeltNoSound':
            if (seatbelt) {
                seatbelt.classList.toggle('active', data.seatbelt);
                if (data.seatbelt) {
                    seatbelt.innerHTML = '<i class="fa-solid fa-bell"></i>';
                } else {
                    seatbelt.innerHTML = '<i class="fa-solid fa-bell-slash"></i>';
                }
            }
            break;
    }
});