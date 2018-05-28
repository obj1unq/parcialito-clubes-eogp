class Club {

	var property actividadesSociales=#{}
	var property equiposParticiopantes=#{}

}

class Equipo{
	
	var property plantel=#{}
	var property capitan
	
}

class Jugador inherits Socio{
	
	var property valorPase
	var property partidosJugados
	
}

class Socio{
	var antiguedad
}

class ActividadSocial{
	
	var property sociosParticipantes=#{}
	var property socioOrganizador
}