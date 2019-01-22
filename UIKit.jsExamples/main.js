class MasterService {
    static async loadData(c) {
        return ['a', 'b', c];
    }
}

this.MasterService = MasterService;
