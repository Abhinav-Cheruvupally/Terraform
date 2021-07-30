variable "username"{
    default = "admin"
}

variable "password"{
    default="pass1234"
}

variable "engine"{
    type=list

    default=["mysql","postgresql"]
}

variable "multidb"{
    type=list

    default=["db1","db2","db3"]
}