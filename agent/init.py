from train import Train
import matplotlib.pyplot as plt
import numpy as np

NEW_TRAIN = False # True -> Reniciar treinamento / False -> Carregar Treinamento existente
PLAYING = True # True -> Jogar o jogo / False -> Realizar Treinamento
SHOWING_CHART = False # True -> Mostrar os graficos sem treinar / False -> Treinar e mostrar os graficos pos treinamentos

# cria treinamento
if NEW_TRAIN:
    train = Train(False, True, PLAYING)
else:
    train = Train(True, playing=PLAYING)

if SHOWING_CHART==False:
    for i in range(10):
        # inicia treinamento
        train.start(15)

# carrega historico e mostra em forma grafica
ep = train.agent.history['ep_reward']
avg = train.agent.history['avg_reward'] 
loss = train.agent.history['loss_history']
acc = train.agent.history['acc_history']
sec = train.agent.history['seconds_history']
scr = train.agent.history['score_history']
obs = np.array(train.agent.history['obs_history'])

plt.plot(scr)
plt.xlabel("Index")
plt.ylabel("Pontuação por episódio")
plt.show()

plt.plot(ep)
plt.xlabel("Index")
plt.ylabel("Recompensa por episódio")
plt.show()

plt.plot(sec)
plt.xlabel("Index")
plt.ylabel("Segundos vivo por episódio")
plt.show()

plt.plot(avg)
plt.xlabel("Index")
plt.ylabel("Média dos episódios")
plt.show()

plt.plot(loss)
plt.xlabel("Index")
plt.ylabel("Função de Perda")
plt.show()

plt.plot(acc)
plt.xlabel("Index")
plt.ylabel("Acuracia")
plt.show()