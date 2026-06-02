#  Intelligent EV Battery Monitoring System (AI + IoT)

##  Introduction

Ce projet propose un **système intelligent de surveillance des batteries pour véhicules électriques (EV)** utilisant l’**Intelligence Artificielle (AI)** et l’**Internet of Things (IoT)**. Le système prédit avec précision le **State of Charge (SOC)** et le **State of Health (SOH)** des batteries lithium-ion, optimisant la performance, la durée de vie et l’efficacité énergétique.

##  Fonctionnement

1. Les capteurs IoT collectent des données en temps réel : tension, courant, température, cycles de charge/décharge.
2. Les données sont envoyées à une plateforme cloud pour traitement.
3. Les modèles AI (DNN, XGBoost, Random Forest, LGBMRegressor) prédisent SOC, SOH et Remaining Useful Life (RUL).
4. Le système fournit des diagnostics précis et des recommandations via une application mobile.

##  Interface Utilisateur

Le système propose deux écrans principaux :

1. **Battery Status** : Affiche SOC, SOH, durée de charge, cycles de charge, température, tension, courant, etc.
2. **Driving Range & Predictions** : Montre la distance restante, le temps estimé pour atteindre la destination, RUL, et prévisions SOC/SOH pour l’heure suivante.

Ces écrans offrent une interface intuitive qui améliore l’expérience de conduite et permet une gestion efficace de l’énergie.

##  Technologies utilisées

* **AI / ML** : DNN, XGBoost, Random Forest, LGBMRegressor
* **IoT** : Capteurs temps réel, collecte de données
* **Python** : Pandas, NumPy, PyTorch
* **Data Processing** : EDA, KDE, SMOTE, Noise Injection
* **Frontend / Cloud** : Application mobile, stockage cloud

##  Fonctionnalités clés

* Prédiction précise de SOC et SOH
* Estimation de RUL
* Surveillance en temps réel des batteries EV
* Optimisation de l’efficacité énergétique et prolongation de la durée de vie
* Visualisation des données et alertes via application mobile

##  Installation & Exécution

1. Installer les dépendances Python


2. Lancer les scripts AI pour prédiction

```bash
python train_model.py
python predict_soc_soh.py
```

3. Accéder à l’application mobile pour visualisation en temps réel.



