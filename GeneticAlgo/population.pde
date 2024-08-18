// //Class Population
class Population {

//Attributes
float   mutationRate;
int     maxPopulation;
ArrayList<Dino> dinoList = new ArrayList<Dino>();

Population (float _mutationRate, int _maxPopulation) {

    this.mutationRate = _mutationRate;
    this.maxPopulation = _maxPopulation;

    for (int i = 0; i < this.maxPopulation; i++) {
        this.dinoList.add(new Dino());
    }
}
}
// void calcFitness() {
//     for (int i = 0; i < this.maxPopulation; i++) {
//         this.population.get(i).calcFitness();
//     }
// }






//}