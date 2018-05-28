class Club {
	var property valorPasePorDefecto=120
	var property actividadesSociales=#{}
	var property equiposParticiopantes=#{}
	var property perfil
	var property gastoMensual
	
	method evaluacion () = perfil.evaluacion(self)
	
	method paticipaActvidadSocial(actividadSocial, jugador){
		return actividadSocial.sociosParticipantes().contains(jugador)
	}
	
	method paticipacionActvidadesSociales( jugador){
		return actividadesSociales.count({actividadSocial=>self.paticipaActvidadSocial(actividadSocial, jugador)})
	}
	
	method esJugadorEstrella(jugador){
		return perfil.esEstrella(jugador, self)
	}

	method cantidadSocios(){
		return actividadesSociales.sum({actividadSocial=>actividadSocial.sociosParticipantes().count()})+
		equiposParticiopantes.sum({equipoparticipante=>equipoparticipante.plantel().count()})
	}
	
	method sancionar(){
		if(self.cantidadSocios()>=500){
			actividadesSociales.foreach({actividadSocial=>actividadSocial.sancionar()})
			equiposParticiopantes.foreach({equipoParticiopante=>equipoParticiopante.sancionar()})
		}
	}
	
	method sancionarActividad(actividad){
		actividad.sancionar()
	}
	
	method reanudarActividad(actividad){
		actividad.levantarSancion()
	}
	
	method cantidadSanciones(equipo){
		equipo.sanciones()
	}

	method actividadSuspendidad(actividad){
		actividad.suspendida()
	}
	
	method sociosDestacados(){
		return actividadesSociales.map({actividadSocial=>actividadSocial.socioOrganizador()}).asSet() +
			equiposParticiopantes.map({equipo=>equipo.capitan()}).asSet()
	}
	
	method sociosEstrella(actividadSocial) = actividadSocial.count({socio=>socio.esEstrella(self)}) >= 5
	
	method actividadEstrella() = actividadesSociales.any({actividad=>self.sociosEstrella(actividad)})
	
	method esPrestigioso() = equiposParticiopantes.any({equipo=>equipo.esExperimentado()}) || self.actividadEstrella()
}

class Equipo{

	var property plantel=#{}
	var property capitan
	var sanciones=0
	var property campeonatos=0
	var property disciplina
	method sancionar(){
		sanciones++
	}
	method sanciones() = sanciones
	method evaluacion(club) = disciplina.evaluacion(self, club)
	method esExperimentado() = plantel.all({jugador=>jugador.experiencia()>=10})
}

class Jugador inherits Socio {
	
	var property valorPase
	var property partidosJugados
	
	override method esEstrella(club) = partidosJugados>50 || club.esJugadorEstrella(self)
	
}

class Socio{
	var antiguedad
	
	method esEstrella(club) = antiguedad>20
}

class ActividadSocial{
	var evalucaion
	var property sociosParticipantes=#{}
	var property socioOrganizador
	var suspendida=false
	
	method sancionar(){
		suspendida=true
	}
	
	method levantarSancion(){
		suspendida=false
	}
	
	method suspendida()=suspendida
	
	method evaluacion(club)= if(suspendida) 0 else evalucaion
}

//perfiles
object tradicional{

	method esEstrella(jugador, club){
		return jugador.valorPase()>club.valorPasePorDefecto() || 
		club.paticipacionActvidadesSociales() > 3
	}
	
	method evaluacionBase(club){
		return club.actividadesSociales().sum({actividadSocial => actividadSocial.evaluacion()}) +
				club.equiposParticiopantes().sum({equipoParticipante => equipoParticipante.evaluacion()})
	}
	
	method evaluacion(club) {
		return self.evaluacionBase(club)-club.gastoMensual()
	} 
	
}

object comunitario{

	method esEstrella(jugador, club){
		return club.paticipacionActvidadesSociales() > 3
	}
	
	method evaluacion(club){
		return club.actividadesSociales().sum({actividadSocial => actividadSocial.evaluacion()}) +
				club.equiposParticiopantes().sum({equipoParticipante => equipoParticipante.evaluacion()})
	}
}

object profesional{

	method esEstrella(jugador, club){
		return jugador.valorPase()>club.valorPasePorDefecto()
	}
	
	method evaluacionBase(club){
		return club.actividadesSociales().sum({actividadSocial => actividadSocial.evaluacion()}) +
				club.equiposParticiopantes().sum({equipoParticipante => equipoParticipante.evaluacion()})
	}
	
	method evaluacion(club) {
		return self.evaluacionBase(club)*2-club.gastoMensual()*5
	}
	
}
//disciplinas 
object futbool{
	method puntajePorEstrellas(equipo, club) = equipo.plantel().count({jugador=>jugador.esEstrella(club)})*5
	method puntajeBase(equipo, club) = equipo.campeonatos()*5+equipo.plantel().size()*2+self.puntajePorEstrellas(equipo, club)-equipo.sanciones()*30
	method evaluacion(equipo, club) = if(equipo.capitan().estrella(club)) equipo.puntajeBase()+10 else equipo.puntajeBase()
	
}
object otraDisciplina{
	method puntajeBase(equipo, club) = equipo.campeonatos()*5+equipo.plantel().size()*2-equipo.sanciones()*20
	method evaluacion(equipo, club) = if(equipo.capitan().estrella(club)) equipo.puntajeBase()+5 else equipo.puntajeBase()
	
}