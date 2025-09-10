public virtual class BadgesBaseCtrl {

    public virtual class Badge{
        public String sldsIconName;
        public String title;
        public String titleClasses;
        public String type;
        public Id recordId;

        public Badge(){}

        public Badge(String sldsIconName, String title){
            this.sldsIconName = sldsIconName;
            this.title = title;
        }

        public Badge(String sldsIconName, String title, String titleClasses){
            this.sldsIconName = sldsIconName;
            this.title = title;
            this.titleClasses = titleClasses;
        }

        public Badge(String sldsIconName, String title, String type, Id recordId){
            this.sldsIconName = sldsIconName;
            this.title = title;
            this.type = type;
            this.recordId = recordId;
        }
    }

    public virtual class BadgesResponse{
        public List<Badge> badges = new List<Badge>();
    }

}