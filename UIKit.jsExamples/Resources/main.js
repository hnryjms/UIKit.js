class MasterService {
    static async loadData() {
        return [
            { title: "Simple Example", scene: "SimpleExample" }
        ]
    }
}

this.MasterService = MasterService;
